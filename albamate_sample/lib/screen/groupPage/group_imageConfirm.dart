import 'dart:io';
import 'package:flutter/material.dart';
import 'group_imageProcessing.dart';

class GroupImageConfirmPage extends StatelessWidget {
  final File imageFile;
  final String userRole;   // 👈 추가
  final String groupId;    // 👈 추가

  const GroupImageConfirmPage({
    super.key,
    required this.imageFile,
    required this.userRole,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('사진 확인')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: h * 0.55,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(imageFile, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 24),
            const Text("이 사진에서 스케줄을 추출할까요?", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.text_snippet),
              label: const Text('스케줄 추출하기'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupImageProcessingPage(
                      imageFile: imageFile,
                      userRole: userRole,
                      groupId: groupId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006FFD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
