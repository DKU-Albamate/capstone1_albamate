import 'package:flutter/material.dart';
import 'create_sub_page.dart';
import 'detail_sub_page.dart';
import 'package:albamate_sample/screen/groupPage/notice/notice_model.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ScreenSubPage extends StatefulWidget {
  final String groupId;

  const ScreenSubPage({required this.groupId, super.key});

  @override
  _ScreenSubPageState createState() => _ScreenSubPageState();
}

class _ScreenSubPageState extends State<ScreenSubPage> {
  List<Notice> notices = [];
  String? userRole;
  String? userUid;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserRoleAndNotices();
  }

  Future<void> _fetchUserRoleAndNotices() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      userUid = user.uid;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && mounted) {
        setState(() => userRole = userDoc['role']);
      }

      final idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse('https://backend-vgbf.onrender.com/api/posts?groupId=${widget.groupId}&category=대타구하기'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          notices = data.map((e) => Notice.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        print('대타 공지 불러오기 실패: ${response.statusCode} - ${response.body}');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('대타 공지 불러오기 오류: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteNotice(String postId) async {
    if (!mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final idToken = await user.getIdToken();

      final response = await http.delete(
        Uri.parse('https://backend-vgbf.onrender.com/api/posts/$postId'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200 && mounted) {
        _fetchUserRoleAndNotices();
      } else {
        print('삭제 실패: ${response.body}');
      }
    } catch (e) {
      print('삭제 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          final isAuthor = userUid != null && userUid == notice.authorUid;
          final canEdit = userRole == '사장님' || isAuthor;

          final koreaDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(notice.createdAt).toLocal());

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 160,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // 🔔 아이콘 정렬 통일
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 7), // 🔔 아이콘 살짝 내림
                          child: Icon(Icons.notifications_none, color: Colors.grey[700], size: 28),
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
                                    MaterialPageRoute(
                                      builder: (context) => DetailSubPage(notice: notice),
                                    ),
                                  ).then((_) {
                                    if (mounted) _fetchUserRoleAndNotices();
                                  });
                                },
                                child: Text(
                                  notice.title,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(koreaDate, style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (canEdit)
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final edited = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateSubPage(groupId: widget.groupId, notice: notice),
                                  ),
                                );
                                if (edited == true && mounted) _fetchUserRoleAndNotices();
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetailSubPage(notice: notice)),
                        ).then((_) {
                          if (mounted) _fetchUserRoleAndNotices();
                        });
                      },
                      child: Text(
                        notice.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: Color(0xFF006FFD),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateSubPage(groupId: widget.groupId)),
          );
          if (created == true && mounted) _fetchUserRoleAndNotices();
        },
        label: Text('CREATE', style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: Colors.white),
      )

    );
  }
}
