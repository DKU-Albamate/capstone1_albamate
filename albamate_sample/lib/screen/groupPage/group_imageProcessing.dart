import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'group_imageParseView.dart';


class Schedule {
  final DateTime date;
  final TimeOfDay start;
  final TimeOfDay end;
  final String title;
  final String name; // ✅ 추가

  Schedule({
    required this.date,
    required this.start,
    required this.end,
    required this.title,
    required this.name,
  });

  factory Schedule.fromJson(Map<String, dynamic> j) {
    try {
      TimeOfDay? _t(String? t) {
        if (t == null || !t.contains(':')) return null;
        final p = t.split(':').map(int.parse).toList();
        return TimeOfDay(hour: p[0], minute: p[1]);
      }

      final dateStr = j['date'];
      final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
      final start = _t(j['start']);
      final end = _t(j['end']);

      if (date == null || start == null || end == null) {
        throw Exception('⛔ 필수 시간정보 누락');
      }

      return Schedule(
        date: date,
        start: start,
        end: end,
        title: j['title'] ?? '포지션 미지정',
        name: j['name'] ?? '이름없음',
      );
    } catch (e) {
      print('❗ Schedule 생성 실패: $e\nJSON: $j');
      rethrow;
    }
  }

  @override
  String toString() {
    final s =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final e =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '${date.month}/${date.day}  $s-$e  $title ($name)';
  }
}

class GroupImageProcessingPage extends StatefulWidget {
  final File imageFile;
  final String userRole;
  final String groupId;

  const GroupImageProcessingPage({
    super.key,
    required this.imageFile,
    required this.userRole,
    required this.groupId,
  });

  @override
  State<GroupImageProcessingPage> createState() =>
      _GroupImageProcessingPageState();
}

class _GroupImageProcessingPageState extends State<GroupImageProcessingPage> {
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

    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 정보가 없습니다.')),
        );
        Navigator.pop(context);
      }
      return;
    }


    try {
      final req = http.MultipartRequest(
        'POST',
        Uri.parse('https://backend-vgbf.onrender.com/ocr/schedule'),// 백엔드 새로 필요
      )
        ..fields['user_uid'] = uid
      // ✅ display_name 제거 → 전체 인물 스케줄 추출 가능
        ..files.add(
          await http.MultipartFile.fromPath('photo', widget.imageFile.path),
        );

      final res = await req.send();
      final body = await res.stream.bytesToString();

      if (res.statusCode != 200 && res.statusCode != 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('업로드 실패 (${res.statusCode})')),
          );
          Navigator.pop(context);
        }
        return;
      }

      final data = jsonDecode(body) as Map<String, dynamic>;

      // ✅ 스케줄 파싱 + 실패 항목 무시
      final List<Schedule> schedules = [];
      for (final e in data['schedules'] ?? []) {
        try {
          schedules.add(Schedule.fromJson(e));
        } catch (_) {}
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GroupImageParseViewPage(
              imageFile: widget.imageFile,
              schedules: schedules,
              userRole: widget.userRole,
              groupId: widget.groupId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
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
          Text(
            '사진에서 일정을 추출 중입니다...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    ),
  );
}
