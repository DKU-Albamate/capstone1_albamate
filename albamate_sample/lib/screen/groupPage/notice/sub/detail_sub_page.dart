import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/groupPage/notice/notice_model.dart';
import 'package:albamate_sample/component/groupHome_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class Comment {
  final String id;
  final String userUid;
  final String content;
  final String userName;

  Comment({
    required this.id,
    required this.userUid,
    required this.content,
    required this.userName,
  });
}

class DetailSubPage extends StatefulWidget {
  final Notice notice;

  const DetailSubPage({super.key, required this.notice});

  @override
  State<DetailSubPage> createState() => _DetailSubPageState();
}

class _DetailSubPageState extends State<DetailSubPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = [];
  String currentUid = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUidAndComments();
  }

  Future<void> _loadCurrentUidAndComments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUid = user.uid;
      await _fetchComments();
    }
  }

  Future<void> _fetchComments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final idToken = await user.getIdToken();

    final response = await http.get(
      Uri.parse(
        'https://backend-vgbf.onrender.com/api/posts/${widget.notice.id}/comments',
      ),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      final List<Comment> loaded = [];

      for (var c in data) {
        final uid = c['user_uid'];
        final name = await _getUserName(uid);
        loaded.add(
          Comment(
            id: c['id'].toString(),
            userUid: uid,
            content: c['content'],
            userName: name,
          ),
        );
      }

      setState(() {
        comments = loaded;
      });
    }
  }

  Future<String> _getUserName(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['name'] ?? '익명';
      }
    } catch (_) {}
    return '익명';
  }

  Future<void> _addComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final idToken = await user.getIdToken();
    final content = _commentController.text.trim();

    if (content.isEmpty) return;

    final response = await http.post(
      Uri.parse(
        'https://backend-vgbf.onrender.com/api/posts/${widget.notice.id}/comments',
      ),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'postId': widget.notice.id, // ✅ 꼭 포함
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      _commentController.clear();
      await _fetchComments();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('댓글 등록에 실패했어요')));
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final idToken = await user.getIdToken();

    final response = await http.delete(
      Uri.parse(
        'https://backend-vgbf.onrender.com/api/posts/${widget.notice.id}/comments/$commentId',
      ),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 200) {
      await _fetchComments();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('댓글 삭제에 실패했어요')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String createdDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.parse(widget.notice.createdAt).toLocal());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '대타 구하기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "Inter",
            color: Colors.black,
          ),
        ),

        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          //home 버튼 누르면 groupHome으로
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => GroupNav(
                        groupId: widget.notice.groupId,
                        // TODO: ⚠️ 현재 userRole 임시 사용 중 (백엔드 ownerId 연동 시 제거 예정)
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
      body: Column(
        children: [
          // 공지 카드
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          createdDate,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 12),
                Text(widget.notice.content),
              ],
            ),
          ),
          Expanded(
            child:
                comments.isEmpty
                    ? Center(child: Text('댓글이 없습니다.'))
                    : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                          ),
                          title: Text(comment.userName),
                          subtitle: Text(comment.content),
                          trailing:
                              comment.userUid == currentUid
                                  ? IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteComment(comment.id),
                                  )
                                  : null,
                        );
                      },
                    ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              color: Colors.grey[100],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '댓글을 작성하세요.',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                ElevatedButton(onPressed: _addComment, child: Text('등록')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
