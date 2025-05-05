import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/groupPage/notice/notice_model.dart';
import 'package:albamate_sample/component/groupHome_navigation.dart';

//대타 구하기 상세페이지
class DetailSubPage extends StatefulWidget {
  final Notice notice;

  DetailSubPage({required this.notice});

  @override
  State<DetailSubPage> createState() => _DetailSubPageState();
}

class _DetailSubPageState extends State<DetailSubPage> {
  final TextEditingController _commentController = TextEditingController();
  List<String> comments = [];

  void _addComment(String comment) {
    setState(() {
      comments.add(comment);
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('대타 구하기', style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "Inter",
            color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [ //home 버튼 누르면 groupHome으로
          IconButton(icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => GroupNav(groupId : widget.notice.groupId)),
                      (Route<dynamic> route) => false,
                );
              }),
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
                        Text(widget.notice.title,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(widget.notice.date,
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.more_vert)
                  ],
                ),
                SizedBox(height: 12),
                Text(widget.notice.content),
              ],
            ),
          ),

          // 댓글 리스트
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.grey[300]),
                  title: Text('이름'),
                  subtitle: Text(comment),
                );
              },
            ),
          ),

          // 댓글 입력 필드 + 등록 버튼
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
                ElevatedButton(
                  onPressed: () {
                    if (_commentController.text.trim().isNotEmpty) {
                      _addComment(_commentController.text.trim());
                    }
                  },
                  child: Text('등록'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
