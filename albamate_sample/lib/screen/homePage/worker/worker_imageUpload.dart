import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'worker_imageParseView.dart';

class WorkerImageUploadPage extends StatefulWidget {
  const WorkerImageUploadPage({super.key});

  @override
  State<WorkerImageUploadPage> createState() => _WorkerImageUploadPageState();
}

class _WorkerImageUploadPageState extends State<WorkerImageUploadPage> {
  File? _selectedImage;

  // 이미지 선택 실행 함수
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkerImageParseViewPage(
            imageFile: File(picked.path),
            parsedSchedule: [
              '텍스트 추출 넣을 예정'
              // TODO: 여기 parsedSchedule은 추후 OCR API 결과로 대체될 예정
              // 예: 서버에 이미지 업로드 → 일정 텍스트 추출 → 여기에 결과 넣기
            ],
          ),
        ),
      );
    }
  }


  // 사진 선택 방식 모달
  void _showImageSourceSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('사진 찍기'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('사진 보관함'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text('취소'),
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
      appBar: AppBar(title: Text("이미지 업로드")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "스케줄표 사진을 업로드하고\n캘린더에 쉽게 연동하세요",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Text("설명 이미지", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
                  : Icon(Icons.image, size: 40, color: Colors.grey),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showImageSourceSelector(context),
                icon: Icon(Icons.upload_file, color: Colors.white),
                label: Text("사진 고르기", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF006FFD),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
