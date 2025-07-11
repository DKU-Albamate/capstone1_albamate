import 'dart:io';
import 'package:flutter/material.dart';
import 'worker_homecalendar.dart';
import 'worker_imageProcessing.dart'; // Schedule 클래스를 재사용

class WorkerImageParseViewPage extends StatelessWidget {
  final File imageFile;
  final List<Schedule> schedules;        // ← 변경

  const WorkerImageParseViewPage({
    super.key,
    required this.imageFile,
    required this.schedules,
  });

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('스케줄 추출 결과')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ▸ 업로드한 사진 (확대 가능)
            Container(
              height: h * 0.45,
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

            // ▸ 추출된 일정 리스트
            Align(
              alignment: Alignment.centerLeft,
              child: Text('추출된 일정',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: schedules.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) => ListTile(
                  leading: const Icon(Icons.event_note),
                  title: Text(schedules[i].toString()),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ▸ 캘린더로 돌아가기
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkerHomecalendar()),
                  (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006FFD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('캘린더로 이동', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

