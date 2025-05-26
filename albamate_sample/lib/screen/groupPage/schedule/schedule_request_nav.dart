import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/groupPage/schedule/create_schedule.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_card.dart';
import 'package:albamate_sample/screen/groupPage/schedule/worker_scheduleView.dart'; // ✅ 추가
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class ScheduleRequestNav extends StatefulWidget {
  final String groupId; // 부모에서 supabase의 groupId 전달받음
  final String userRole;

  const ScheduleRequestNav({
    super.key,
    required this.groupId,
    required this.userRole,
  });

  @override
  State<ScheduleRequestNav> createState() => _ScheduleRequestNavState();
}

class _ScheduleRequestNavState extends State<ScheduleRequestNav> {
  List<Map<String, dynamic>> schedulePosts = [];

  @override
  void initState() {
    super.initState();
    fetchSchedulePosts();
  }
Future<void> fetchSchedulePosts() async {
  try {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken(); // Firebase 사용 중이므로 이 토큰 사용

    final response = await http.get(
      Uri.parse('https://backend-schedule-vs8b.onrender.com/api/schedules?groupId=${widget.groupId}'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      setState(() {
        schedulePosts = data.map<Map<String, dynamic>>((item) {
          return {
            'id': item['_id'],
            'title': item['title'],
            'description': item['description'],
            'year': item['year'],
            'month': item['month'],
            'createdAt': item['createdAt'],
          };
        }).toList();
      });
    } else {
      print('❌ 서버 응답 오류: ${response.body}');
    }
  } catch (e) {
    print('❌ 스케줄 불러오기 실패: $e');
  }
}


  void _addSchedulePost(Map<String, dynamic> newPost) {
    setState(() {
      schedulePosts.add(newPost);
    });
  }

  void _handleCreatePost() async {
    final newPost = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => CreateSchedulePostPage(groupId: widget.groupId),
    ),
    );
    if (newPost != null) {
      final enrichedPost = {
        'id': newPost['scheduleId'],
        'title': newPost['title'],
        'description': newPost['description'],
        'year': newPost['year'],
        'month': newPost['month'],
        'createdAt': DateTime.now().toIso8601String(),
      };
      _addSchedulePost(enrichedPost);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ...schedulePosts.map((post) {
            return ScheduleCard(
              title: post['title'] ?? '',
              description: post['description'] ?? '',
              createdAt: post['createdAt'] ?? '',
              scheduleId: post['id'],
              year: post['year'],
              month: post['month'],
              // TODO: ⚠️ 현재 userRole 임시 사용 중 (백엔드 ownerId 연동 시 제거 예정)
              userRole: widget.userRole,
              groupId: widget.groupId,
            );
          }).toList(),
          const SizedBox(height: 32),
           ],
      ),
          floatingActionButton:
          widget.userRole == '사장님'
              ? FloatingActionButton.extended(
                onPressed: _handleCreatePost,
                backgroundColor: Colors.blue,
                label: const Text('CREATE'),
                icon: const Icon(Icons.add),
              )
              : null,
    );
  }
}
