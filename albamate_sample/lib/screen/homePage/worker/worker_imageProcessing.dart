import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'worker_imageParseView.dart';

/// ─────────────────────────────────────────
///  📌 OCR 응답용 모델
/// ─────────────────────────────────────────
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
      date:  DateTime.parse(j['date']), // 2025-07-07
      start: _t(j['start']),            // 09:00
      end:   _t(j['end']),              // 15:30
      title: j['title'],                // 포지션1
    );
  }

  @override
  String toString() {
    final s = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final e = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '${date.month}/${date.day}  $s-$e  $title';
  }
}

/// ─────────────────────────────────────────
///  ⏳ 로딩 화면 – 백엔드 OCR 업로드
/// ─────────────────────────────────────────
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
    _uploadAndParse();
  }

  /// 이미지 + 이름/UID 업로드 → 일정 리스트 수신
  Future<void> _uploadAndParse() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid  = user?.uid;
    final name = user?.displayName;          // ← 로그인 시 저장한 **직원 이름**

    // 필수 정보 없으면 알림 후 종료
    if (uid == null || name == null || name.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 정보(UID/이름)가 없습니다.')),
        );
        Navigator.pop(context);
      }
      return;
    }

    try {
      // ① multipart 요청
      final req = http.MultipartRequest(
        'POST',
        Uri.parse('https://backend-vgbf.onrender.com/ocr/schedule'),
      )
        ..fields['user_uid']     = uid
        ..fields['display_name'] = name
        ..files.add(await http.MultipartFile.fromPath(
          'photo',
          widget.imageFile.path,
        ));

      final res  = await req.send();
      final body = await res.stream.bytesToString();

      // ② 실패 처리
      if (res.statusCode != 200 && res.statusCode != 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('업로드 실패 (${res.statusCode})')),
          );
          Navigator.pop(context);
        }
        return;
      }

      // ③ JSON → List<Schedule>
      final data = jsonDecode(body) as Map<String, dynamic>;
      final List<Schedule> schedules =
          (data['schedules'] as List? ?? [])
              .map<Schedule>((e) => Schedule.fromJson(e))
              .toList();

      // ④ 미리보기 페이지로
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WorkerImageParseViewPage(
              imageFile: widget.imageFile,
              schedules: schedules,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
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
