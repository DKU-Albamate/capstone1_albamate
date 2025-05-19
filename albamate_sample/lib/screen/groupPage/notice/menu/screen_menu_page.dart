import 'package:flutter/material.dart';
import 'create_menu_page.dart';
import 'detail_menu_page.dart';
import 'package:albamate_sample/screen/groupPage/notice/notice_model.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Firestore
import 'package:intl/intl.dart';
import 'dart:convert';

//신메뉴 공지 화면 페이지

class ScreenMenuPage extends StatefulWidget {
  final String groupId;

  const ScreenMenuPage({required this.groupId, super.key});

  @override
  _ScreenMenuPageState createState() => _ScreenMenuPageState();
}

class _ScreenMenuPageState extends State<ScreenMenuPage> {
  List<Notice> notices = [];
  String? userRole;
  String? userUid;

  @override
  void initState() {
    super.initState();
    _fetchUserRoleAndNotices();
  }

  Future<void> _fetchUserRoleAndNotices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    userUid = user.uid;

    // 🔵 Firestore에서 역할 가져오기
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      setState(() {
        userRole = userDoc['role']; // '사장님' 또는 '알바생'
      });
    }

    final idToken = await user.getIdToken();

    final response = await http.get(
      Uri.parse('https://backend-vgbf.onrender.com/api/posts?groupId=${widget.groupId}&category=신메뉴공지'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      setState(() {
        notices = data.map((e) => Notice.fromJson(e)).toList();
      });
    } else {
      print('목록 불러오기 실패: ${response.body}');
    }
  }

  Future<void> _deleteNotice(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idToken = await user.getIdToken();

    final response = await http.delete(
      Uri.parse('https://backend-vgbf.onrender.com/api/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      _fetchUserRoleAndNotices();
    } else {
      print('삭제 실패: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          final isAuthor = userUid != null && userUid == notice.authorUid;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: notice.imageUrl != null && notice.imageUrl!.isNotEmpty ? 248 : 148,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          color: Colors.grey[700],
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => DetailMenuPage(notice: notice)),
                                  );
                                },
                                child: Text(
                                  notice.title,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                  DateFormat('yyyy-MM-dd').format(DateTime.parse(notice.createdAt).toLocal()),
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        // ✅ 사장님이면서 본인 글일 때만 수정/삭제 메뉴 보이게
                        if (userRole == '사장님' && isAuthor)
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final edited = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateMenuPage(groupId: widget.groupId, notice: notice),
                                  ),
                                );
                                if (edited == true) _fetchUserRoleAndNotices();
                              } else if (value == 'delete') {
                                await _deleteNotice(notice.id);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'edit', child: Text('수정하기')),
                              PopupMenuItem(value: 'delete', child: Text('삭제하기')),
                            ],
                            icon: Icon(Icons.more_vert),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DetailMenuPage(notice: notice)),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (notice.imageUrl != null && notice.imageUrl!.isNotEmpty)
                              Container(
                                height: 100,
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    notice.imageUrl!,
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
                            Text(
                              notice.content,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // ✅ 사장님만 작성 버튼 보이게
      floatingActionButton: (userRole == '사장님')
          ? FloatingActionButton.extended(
              backgroundColor: Color(0xFF006FFD),
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateMenuPage(groupId: widget.groupId),
                  ),
                );
                if (created == true) _fetchUserRoleAndNotices();
              },
              label: Text('Create', style: TextStyle(color: Colors.white)),
              icon: Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
