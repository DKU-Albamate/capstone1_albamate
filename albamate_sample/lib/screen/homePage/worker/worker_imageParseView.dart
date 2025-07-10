import 'dart:io';
import 'package:flutter/material.dart';
import 'worker_homecalendar.dart'; // 캘린더 페이지로 이동하기 위해 import 필요

class WorkerImageParseViewPage extends StatelessWidget {
  final File imageFile;
  final List<String> parsedSchedule;

  const WorkerImageParseViewPage({
    super.key,
    required this.imageFile,
    required this.parsedSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text("스케줄 추출 결과")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 사진 크게 표시 (1/2 화면 높이 사용)
            Container(
              height: screenHeight * 0.45, // 화면의 45% 차지
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InteractiveViewer(
                  child: Image.file(imageFile, fit: BoxFit.contain),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 텍스트 추출 결과 제목
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "추출된 일정",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            // 텍스트 리스트 (남은 높이 안에서 스크롤 가능)
            Expanded(
              child: ListView.builder(
                itemCount: parsedSchedule.length,
                itemBuilder:
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(parsedSchedule[index]),
                    ),
              ),
            ),

            const SizedBox(height: 12),

            // 캘린더 연동 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 캘린더 페이지로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => WorkerHomecalendar()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006FFD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("캘린더 연동", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
