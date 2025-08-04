import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'worker_imageParseView.dart';
import 'worker_homecalendar.dart';
import 'dart:async'; // ✅ TimeoutException을 사용


class Schedule {
  DateTime date;
  TimeOfDay start;
  TimeOfDay end;
  String title;

  Schedule({
    required this.date,
    required this.start,
    required this.end,
    required this.title,
  });

   Schedule copy() {
    return Schedule(
      date: DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch),
      start: TimeOfDay(hour: start.hour, minute: start.minute),
      end: TimeOfDay(hour: end.hour, minute: end.minute),
      title: title,
    );
  }

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

  factory Schedule.empty() {
    final now = DateTime.now();
    return Schedule(
      title: '',
      date: now,
      start: const TimeOfDay(hour: 9, minute: 0),
      end: const TimeOfDay(hour: 15, minute: 0),
    );
  }

  @override
  String toString() {
    final s = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final e = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '${date.month}/${date.day}  $s-$e  $title';
  }
}

class WorkerImageProcessingPage extends StatefulWidget {
  final File imageFile;
  const WorkerImageProcessingPage({super.key, required this.imageFile});

  @override
  State<WorkerImageProcessingPage> createState() => _WorkerImageProcessingPageState();
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

    if (uid == null || name == null || name
        .trim()
        .isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 정보(UID/이름)가 없습니다.')),
        );
        Navigator.pop(context);
      }
      return;
    }

    final finalName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: const Text('스케줄 추출 이름 확인'),
            content: Text(
                '$name 님의 스케줄을 추출할까요?\n\n🤖 Gemini 2.5 Flash Lite AI가 정확하게 분석합니다.'),
            actions: [
              TextButton(
                child: const Text('아니오'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WorkerHomecalendar()),
                        (route) => false,
                  );
                },
              ),
              TextButton(
                child: const Text('예'),
                onPressed: () => Navigator.pop(context, name),
              ),
            ],
          ),
    );

    if (finalName == null || finalName
        .trim()
        .isEmpty) return;

    try {
      // 🤖 Gemini 2.5 Flash Lite 전용 엔드포인트 사용
      final req = http.MultipartRequest(
        'POST',
        Uri.parse('https://backend-vgbf.onrender.com/ocr/schedule/gemini'),
      )
        ..fields['user_uid'] = uid
        ..fields['display_name'] = finalName
        ..fields['use_gemini'] = 'true'
        ..fields['gemini_seed'] = '42'  // 안정적인 seed 값
        ..fields['gemini_temperature'] = '0.05'  // 매우 낮은 temperature (일관성)
        ..fields['gemini_top_p'] = '0.3'  // 보수적인 topP 값 (정확성)
        ..fields['max_retries'] = '5'  // 최대 재시도 횟수 증가
        ..files.add(
            await http.MultipartFile.fromPath('photo', widget.imageFile.path));

      // 디버깅: 요청 정보 출력
      print('📤 앱에서 보내는 요청:');
      print('   URL: ${req.url}');
      print('   user_uid: $uid');
      print('   display_name: $finalName');
      print('   gemini_seed: 42');
      print('   gemini_temperature: 0.05');
      print('   gemini_top_p: 0.3');
      print('   max_retries: 5');
      print('   image_path: ${widget.imageFile.path}');
      print('   image_size: ${await widget.imageFile.length()} bytes');

      // ✅ 동시 요청 타임아웃 처리
      final res = await req.send().timeout(const Duration(seconds: 20));

      final body = await res.stream.bytesToString();

      // ✅ 응답 로그 출력
      print('📥 응답 수신: statusCode = ${res.statusCode}');
      print('📦 응답 내용: $body');

      // ✅ 400 Bad Request 예외 처리
      if (res.statusCode == 400) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ 요청 오류: 지원하지 않는 형식입니다.')),
          );
          Navigator.pop(context);
        }
        return;
      }

      // ✅ 500 Internal Server Error 예외 처리
      else if (res.statusCode >= 500) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('💥 서버 오류: 잠시 후 다시 시도해주세요.')),
          );
          Navigator.pop(context);
        }
        return;
      }

      // ✅ 기타 예외 처리
      else if (res.statusCode != 200 && res.statusCode != 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('업로드 실패 (${res.statusCode})')),
          );
          Navigator.pop(context);
        }
        return;
      }

      final data = jsonDecode(body) as Map<String, dynamic>;

      if (data['retry_info'] != null) {
        print('🔄 재시도 정보: ${data['retry_info']}');
      }

      final List<Schedule> schedules = (data['schedules'] as List? ?? [])
          .map<Schedule>((e) => Schedule.fromJson(e))
          .toList();

      print('✅ 파싱된 일정 수: ${schedules.length}');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                WorkerImageParseViewPage(
                  imageFile: widget.imageFile,
                  schedules: schedules,
                ),
          ),
        );
      }
    } on SocketException {
      // ✅ 네트워크 연결 오류 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📡 네트워크 오류: 인터넷 연결을 확인해주세요.')),
        );
        Navigator.pop(context);
      }
    } on TimeoutException {
      // ✅ 요청 타임아웃 예외 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⏱️ 요청 시간 초과: 서버가 응답하지 않습니다.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // ✅ 기타 예외 처리
      print('❌ 예외 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(
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
