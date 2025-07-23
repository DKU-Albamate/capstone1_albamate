import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'group_imageConfirm.dart'; // 경로 확인

class GroupImageUploadPage extends StatefulWidget {
  final String userRole;
  final String groupId;

  const GroupImageUploadPage({
    super.key,
    required this.userRole,
    required this.groupId,
  });

  @override
  State<GroupImageUploadPage> createState() => _GroupImageUploadPageState();
}

class _GroupImageUploadPageState extends State<GroupImageUploadPage> {
  File? _selectedImage;

  // 이미지 선택 함수
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupImageConfirmPage(
            imageFile: File(picked.path),
            userRole: widget.userRole,
            groupId: widget.groupId,
          ),
        ),
      );
    }
  }

  // 이미지 소스 선택 모달
  void _showImageSourceSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('사진 찍기'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('사진 보관함'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('취소'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("이미지 업로드")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "스케줄표 사진을 업로드하고\n캘린더에 쉽게 연동하세요",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),

            Image.asset(
              'assets/images/schedule_ai_calendar.png',
              width: 320,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 18),

            const Text(
              "사진만 올리면, 일정이 자동으로 등록돼요!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "예시처럼 스케줄표를 올려주세요",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 60),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showImageSourceSelector(context),
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: const Text(
                  "사진 고르기",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006FFD),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
