import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/groupPage/notice/notice_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'autoCreateGuide.dart'; // 자동 생성 페이지 import

class CreateGuidePage extends StatefulWidget {
  final String groupId;
  final Notice? notice;
  const CreateGuidePage({required this.groupId, this.notice, super.key});

  @override
  _CreateGuidePageState createState() => _CreateGuidePageState();
}

class _CreateGuidePageState extends State<CreateGuidePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  int _selectedIndex = 0;
  File? _selectedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.notice != null) {
      _titleController.text = widget.notice!.title;
      _contentController.text = widget.notice!.content;
      _imageUrl = widget.notice!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idToken = await user.getIdToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://backend-vgbf.onrender.com/api/posts/upload-image'),
    );

    request.headers['Authorization'] = 'Bearer $idToken';
    request.files.add(
      await http.MultipartFile.fromPath('image', _selectedImage!.path),
    );

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        _imageUrl = data['imageUrl'];
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지 업로드 실패')));
    }
  }

  Future<void> _submitPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idToken = await user.getIdToken();

    final isEditing = widget.notice != null;
    final url =
        isEditing
            ? 'https://backend-vgbf.onrender.com/api/posts/${widget.notice!.id}'
            : 'https://backend-vgbf.onrender.com/api/posts';

    final method = isEditing ? 'PUT' : 'POST';
    final request =
        http.Request(method, Uri.parse(url))
          ..headers.addAll({
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          })
          ..body = jsonEncode({
            'groupId': widget.groupId,
            'title': _titleController.text,
            'content': _contentController.text,
            'category': '안내사항',
            'imageUrl': _imageUrl,
          });

    final response = await request.send();
    final resBody = await http.Response.fromStream(response);

    if (resBody.statusCode == 200 || resBody.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('글 작성/수정 실패')));
    }
  }

  Future<void> _deletePost() async {
    if (widget.notice == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idToken = await user.getIdToken();

    final response = await http.delete(
      Uri.parse(
        'https://backend-vgbf.onrender.com/api/posts/${widget.notice!.id}',
      ),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제 실패')));
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      _pickImage();
    } else if (index == 1) {
      _deletePost();
    } else if (index == 2) {
      _submitPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy/MM/dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('안내사항', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "제목을 입력해주세요",
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(formattedDate, style: TextStyle(color: Colors.grey)),
            Divider(),
            SizedBox(height: 12),

            // 안내 문구 + 자동 생성 버튼을 한 줄로 정렬
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "공지사항 작성이 어렵게 느껴진다면?",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AutoCreateGuidePage()),
                    );
                    if (result != null && result is String) {
                      setState(() {
                        _contentController.text = result;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF006FFD),
                  ),
                  child: Text("자동 생성", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 12),

            if (_selectedImage != null || _imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image:
                      _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : NetworkImage(_imageUrl!) as ImageProvider,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: "내용을 입력해주세요",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12), // ← hint를 위로
                      ),
                      maxLines: null,
                      expands: true,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.format_bold),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.format_align_left),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.text_fields),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: "사진넣기"),
          BottomNavigationBarItem(icon: Icon(Icons.delete), label: "삭제하기"),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: "등록하기"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
