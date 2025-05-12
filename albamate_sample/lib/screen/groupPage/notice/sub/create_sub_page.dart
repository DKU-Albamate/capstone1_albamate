import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/groupPage/notice/notice_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class CreateSubPage extends StatefulWidget {
  final String groupId;
  final Notice? notice;
  const CreateSubPage({required this.groupId, this.notice, super.key});

  @override
  _CreateSubPageState createState() => _CreateSubPageState();
}

class _CreateSubPageState extends State<CreateSubPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.notice != null) {
      _titleController.text = widget.notice!.title;
      _contentController.text = widget.notice!.content;
    }
  }

  Future<void> _submitPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idToken = await user.getIdToken();

    final url = widget.notice == null
        ? Uri.parse('https://backend-vgbf.onrender.com/api/posts')
        : Uri.parse('https://backend-vgbf.onrender.com/api/posts/${widget.notice!.id}');

    final response = await (widget.notice == null
        ? http.post(url,
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'groupId': widget.groupId,
              'title': _titleController.text,
              'content': _contentController.text,
              'category': '대타구하기',
            }))
        : http.put(url,
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'title': _titleController.text,
              'content': _contentController.text,
            })));

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: ${response.body}')),
      );
    }
  }

  Future<void> _deletePost() async {
    if (widget.notice == null) return;
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user!.getIdToken();

    final response = await http.delete(
      Uri.parse('https://backend-vgbf.onrender.com/api/posts/${widget.notice!.id}'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${response.body}')),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      _deletePost();
    } else if (index == 1) {
      _submitPost();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy/MM/dd').format(DateTime.now());

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
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "제목을 입력하시오",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(formattedDate, style: TextStyle(color: Colors.grey)),
            Divider(thickness: 1),
            SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: "내용을 입력하시오",
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            IndexedStack(index: _selectedIndex, children: [Container(), Container()]),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 88,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.delete), label: "삭제하기"),
            BottomNavigationBarItem(icon: Icon(Icons.upload), label: "등록하기"),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.grey,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
