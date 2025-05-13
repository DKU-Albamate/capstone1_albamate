import 'package:flutter/material.dart';
import 'detail_guide_page.dart';
import 'create_guide_page.dart';
import 'package:albamate_sample/screen/groupPage/notice/notice_model.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Firestore 추가
import 'package:intl/intl.dart';
import 'dart:convert';

class ScreenGuidePage extends StatefulWidget {
  final String groupId;

  const ScreenGuidePage({required this.groupId, super.key});
  @override
  _ScreenGuidePageState createState() => _ScreenGuidePageState();
}

class _ScreenGuidePageState extends State<ScreenGuidePage> {
  List<Notice> notices = [];
  String? userRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserRoleAndNotices();
  }

  Future<void> _fetchUserRoleAndNotices() async {
    if (!mounted) return; // 위젯이 마운트되어 있는지 확인

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ✅ Firestore에서 역할 가져오기
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (userDoc.exists && mounted) {
        // mounted 확인 추가
        setState(() {
          userRole = userDoc['role']; // '사장님' 또는 '알바생'
        });
      }

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse(
          'https://backend-vgbf.onrender.com/api/posts?groupId=${widget.groupId}&category=안내사항',
        ),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200 && mounted) {
        // mounted 확인 추가
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          notices = data.map((e) => Notice.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        print('공지 목록 불러오기 실패: ${response.statusCode} - ${response.body}');
        if (mounted) {
          // mounted 확인 추가
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('공지 목록 불러오기 오류: $e');
      if (mounted) {
        // mounted 확인 추가
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNotice(String postId) async {
    if (!mounted) return; // 위젯이 마운트되어 있는지 확인

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final idToken = await user.getIdToken();

      final response = await http.delete(
        Uri.parse('https://backend-vgbf.onrender.com/api/posts/$postId'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200 && mounted) {
        // mounted 확인 추가
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
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: notices.length,
                itemBuilder: (context, index) {
                  final notice = notices[index];
                  final isAuthor =
                      currentUser != null &&
                      currentUser.uid == notice.authorUid;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    width: double.infinity,
                    height: 148,
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  color: Colors.grey[700],
                                  size: 28,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => DetailGuidePage(
                                                    notice: notice,
                                                  ),
                                            ),
                                          ).then((_) {
                                            // 돌아왔을 때 새로고침이 필요하다면 여기서 실행
                                            if (mounted) {
                                              _fetchUserRoleAndNotices();
                                            }
                                          });
                                        },
                                        child: Text(
                                          notice.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        DateFormat('yyyy-MM-dd').format(
                                          DateTime.parse(
                                            notice.createdAt,
                                          ).toLocal(),
                                        ),
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isAuthor)
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        final edited = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => CreateGuidePage(
                                                  groupId: widget.groupId,
                                                  notice: notice,
                                                ),
                                          ),
                                        );
                                        if (edited == true && mounted) {
                                          // mounted 확인 추가
                                          _fetchUserRoleAndNotices();
                                        }
                                      } else if (value == 'delete') {
                                        await _deleteNotice(notice.id);
                                      }
                                    },
                                    itemBuilder:
                                        (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Text('수정하기'),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text('삭제하기'),
                                          ),
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
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              DetailGuidePage(notice: notice),
                                    ),
                                  ).then((_) {
                                    // 돌아왔을 때 새로고침이 필요하다면 여기서 실행
                                    if (mounted) {
                                      _fetchUserRoleAndNotices();
                                    }
                                  });
                                },
                                child: Text(
                                  notice.content,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 4,
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
      // ✅ 알바생은 버튼 안 보임
      floatingActionButton:
          (userRole == '사장님')
              ? FloatingActionButton.extended(
                backgroundColor: Color(0xFF006FFD),
                onPressed: () async {
                  final created = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CreateGuidePage(groupId: widget.groupId),
                    ),
                  );
                  if (created == true && mounted) {
                    // mounted 확인 추가
                    _fetchUserRoleAndNotices();
                  }
                },
                label: Text('Create', style: TextStyle(color: Colors.white)),
                icon: Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }
}
