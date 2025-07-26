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
    TimeOfDay _t(String? t) {
      if (t == null || t.isEmpty) {
        return TimeOfDay(hour: 0, minute: 0);
      }
      final p = t.split(':').map(int.parse).toList();
      return TimeOfDay(hour: p[0], minute: p[1]);
    }

    return Schedule(
      date: DateTime.parse(j['date'] ?? DateTime.now().toIso8601String()),
      start: _t(j['start']),
      end: _t(j['end']),
      title: j['title'] ?? j['position'] ?? j['name'] ?? '근무',
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
          content: Text('$name 님의 스케줄을 추출할까요?\n\n🤖 Gemini 2.5 Flash Lite AI가 정확하게 분석합니다.'),
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
      // 🤖 Gemini 2.5 Flash Lite 전용 엔드포인트 사용
      final req =
          http.MultipartRequest(
              'POST',
              Uri.parse('https://backend-vgbf.onrender.com/ocr/schedule/gemini'),
            )
            ..fields['user_uid'] = uid
            ..fields['display_name'] = finalName
            ..fields['use_gemini'] = 'true'
            ..fields['gemini_seed'] = '12345'  // 고정된 seed 값
            ..fields['gemini_temperature'] = '0.1'  // 낮은 temperature
            ..fields['gemini_top_p'] = '0.8'  // 기본 topP 값
            ..fields['max_retries'] = '3'  // 최대 재시도 횟수
            ..files.add(
              await http.MultipartFile.fromPath('photo', widget.imageFile.path),
            );

      // 디버깅: 요청 정보 출력
      print('📤 앱에서 보내는 요청:');
      print('   URL: ${req.url}');
      print('   user_uid: $uid');
      print('   display_name: $finalName');
      print('   gemini_seed: 12345');
      print('   gemini_temperature: 0.1');
      print('   gemini_top_p: 0.8');
      print('   max_retries: 3');
      print('   image_path: ${widget.imageFile.path}');
      print('   image_size: ${await widget.imageFile.length()} bytes');

      final res = await req.send();
      final body = await res.stream.bytesToString();

      // 디버깅: 응답 정보 출력
      print('📥 백엔드 응답:');
      print('   Status Code: ${res.statusCode}');
      print('   Response Body: $body');

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
      
      // 디버깅: 응답 데이터 확인
      print('🔍 백엔드 응답: $data');
      
      final List<Schedule> schedules = [];
      
      if (data['schedules'] != null) {
        final schedulesList = data['schedules'] as List;
        print('📋 schedules 배열 길이: ${schedulesList.length}');
        
        for (var item in schedulesList) {
          try {
            if (item is Map<String, dynamic>) {
              print('📝 일정 데이터: $item');
              final schedule = Schedule.fromJson(item);
              schedules.add(schedule);
              print('✅ 일정 파싱 성공: ${schedule.toString()}');
            }
          } catch (e) {
            print('❌ 일정 파싱 오류: $e, 데이터: $item');
          }
        }
      } else {
        print('❌ schedules 필드가 없습니다');
      }
      
      print('✅ 파싱된 일정 수: ${schedules.length}');

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
      print('❌ 전체 처리 오류: $e');
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
