import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'worker_imageParseView.dart';
import 'worker_homecalendar.dart'; // ✅ 캘린더 페이지 import

class Schedule {
  final DateTime date;
  final TimeOfDay start;
  final TimeOfDay end;
  final String title;

  Schedule({
    required this.date,
    required this.start,
    required this.end,
    required this.title,
  });

  factory Schedule.fromJson(Map<String, dynamic> j) {
    TimeOfDay _t(String t) {
      final p = t.split(':').map(int.parse).toList();
      return TimeOfDay(hour: p[0], minute: p[1]);
    }

    return Schedule(
      date: DateTime.parse(j['date']),
      start: _t(j['start']),
      end: _t(j['end']),
      title: j['title'],
    );
  }

  @override
  String toString() {
    final s =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final e =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '${date.month}/${date.day}  $s-$e  $title';
  }
}

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _uploadAndParse();
    });
  }

  Future<void> _uploadAndParse() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final name = user?.displayName;

    if (uid == null || name == null || name.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로그인 정보(UID/이름)가 없습니다.')));
        Navigator.pop(context);
      }
      return;
    }

    // ✅ 이름 확인 다이얼로그
    final finalName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('스케줄 추출 이름 확인'),
          content: Text('$name 님의 스케줄을 추출할까요?'),
          actions: [
            TextButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkerHomecalendar()),
                  (route) => false,
                );
              },
            ),
            TextButton(
              child: const Text('예'),
              onPressed: () => Navigator.pop(context, name),
            ),
          ],
        );
      },
    );

    if (finalName == null || finalName.trim().isEmpty) return;

    try {
      final req =
          http.MultipartRequest(
              'POST',
              Uri.parse('https://backend-vgbf.onrender.com/ocr/schedule'),
            )
            ..fields['user_uid'] = uid
            ..fields['display_name'] = finalName
            ..files.add(
              await http.MultipartFile.fromPath('photo', widget.imageFile.path),
            );

      final res = await req.send();
      final body = await res.stream.bytesToString();

      if (res.statusCode != 200 && res.statusCode != 201) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('업로드 실패 (${res.statusCode})')));
          Navigator.pop(context);
        }
        return;
      }

      final data = jsonDecode(body) as Map<String, dynamic>;
      final List<Schedule> schedules =
          (data['schedules'] as List? ?? [])
              .map<Schedule>((e) => Schedule.fromJson(e))
              .toList();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => WorkerImageParseViewPage(
                  imageFile: widget.imageFile,
                  schedules: schedules,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류: $e')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('사진에서 일정을 추출 중입니다...', style: TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}
