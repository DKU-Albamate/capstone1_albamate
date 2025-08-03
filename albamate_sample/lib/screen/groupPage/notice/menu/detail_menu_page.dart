import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:albamate_sample/screen/groupPage/notice/notice_model.dart';
import 'package:albamate_sample/component/groupHome_navigation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class DetailMenuPage extends StatefulWidget {
  final Notice notice;

  const DetailMenuPage({super.key, required this.notice});

  @override
  State<DetailMenuPage> createState() => _DetailMenuPageState();
}

class _DetailMenuPageState extends State<DetailMenuPage> {
  bool isChecked = false;
  bool _showSummary = false;
  String? _summary;
  bool _isLoadingSummary = false;

  @override
  void initState() {
    super.initState();
    _fetchCheckmark();
  }

  Future<void> _fetchCheckmark() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idToken = await user.getIdToken();

    final response = await http.get(
      Uri.parse(
        'https://backend-vgbf.onrender.com/api/posts/${widget.notice.id}/checkmark',
      ),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        isChecked = data['isChecked'] ?? false;
      });
    }
  }

  Future<void> _updateCheckmark(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idToken = await user.getIdToken();

    final response = await http.post(
      Uri.parse(
        'https://backend-vgbf.onrender.com/api/posts/${widget.notice.id}/checkmark',
      ),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'postId': widget.notice.id, 'isChecked': value}),
    );

    if (response.statusCode != 200) {
      print('체크박스 업데이트 실패: ${response.body}');
    }
  }

  Future<void> _fetchSummary() async {
    setState(() {
      _isLoadingSummary = true;
    });

    final response = await http.post(
      Uri.parse('https://backend-vgbf.onrender.com/notice/llmSummary'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': widget.notice.content}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _summary = data['summary'];
        _showSummary = true;
        _isLoadingSummary = false;
      });
    } else {
      setState(() {
        _isLoadingSummary = false;
      });
      print('요약 실패: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(widget.notice.createdAt).toLocal());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '신메뉴 공지',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "Inter",
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupNav(
                    groupId: widget.notice.groupId,
                    userRole: '',
                    initialIndex: 2,
                  ),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 요약하기 버튼
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  if (_summary != null) {
                    setState(() {
                      _showSummary = !_showSummary;
                    });
                  } else {
                    _fetchSummary();
                  }
                },
                child: Text(
                  _showSummary ? '요약 숨기기' : '요약하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // ✅ 요약 결과
            AnimatedCrossFade(
              firstChild: SizedBox.shrink(),
              secondChild: _isLoadingSummary
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(
                        _summary ?? '',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
              crossFadeState: _showSummary
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 300),
            ),

            // ✅ 작성자 / 날짜
            Row(
              children: [
                CircleAvatar(backgroundColor: Colors.grey[300], radius: 20),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.notice.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(formattedDate, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 20),

            // ✅ 이미지
            if (widget.notice.imageUrl != null &&
                widget.notice.imageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 200,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.notice.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.error_outline, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),

            Text(widget.notice.content),
            SizedBox(height: 80),/// ✅ 하단 체크박스 침범 방지
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            children: [
              MSHCheckbox(
                size: 22,
                value: isChecked,
                colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                  checkedColor: Colors.blue,
                ),
                style: MSHCheckboxStyle.fillScaleColor,
                onChanged: (selected) {
                  setState(() {
                    isChecked = selected;
                  });
                  _updateCheckmark(selected);
                },
              ),
              SizedBox(width: 8),
              Text('확인', style: TextStyle(color: Colors.grey[800])),
            ],
          ),
        ),
      ),
    );
  }
}
