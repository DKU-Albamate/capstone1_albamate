import 'dart:io';
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text("사진 검색"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //사진 크게 + 확대 가능
            Container(
              height: 320, // 사진 공간 더 크게
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InteractiveViewer(
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ====텍스트 추출 결과 (예정)===
            Align(
              alignment: Alignment.centerLeft,
              child: Text("추출된 일정", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),

            // 리스트 출력
            Expanded(
              child: ListView.builder(
                itemCount: parsedSchedule.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(parsedSchedule[index]),
                ),
              ),
            ),

            // 캘린더 연동 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 캘린더 반영 로직
                },
                child: Text("캘린더 연동"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF006FFD),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
