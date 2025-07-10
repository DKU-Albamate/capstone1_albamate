import 'dart:io';
import 'package:flutter/material.dart';
import 'worker_imageParseView.dart';

class WorkerImageProcessingPage extends StatefulWidget {
  final File imageFile;

  const WorkerImageProcessingPage({super.key, required this.imageFile});

  @override
  State<WorkerImageProcessingPage> createState() =>
      _WorkerImageProcessingPageState();
}

class _WorkerImageProcessingPageState extends State<WorkerImageProcessingPage> {
  @override
  void initState() {
    super.initState();

    // OCR 처리 시뮬레이션
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => WorkerImageParseViewPage(
                imageFile: widget.imageFile,
                parsedSchedule: [
                  '텍스트 추출 넣을 예정',
                  // TODO: 실제 OCR 결과로 대체할 예정
                ],
              ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text("사진에서 일정을 추출 중입니다...", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
