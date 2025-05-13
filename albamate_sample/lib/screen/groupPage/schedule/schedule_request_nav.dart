import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/groupPage/schedule/create_schedule.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_card.dart';
import 'package:albamate_sample/screen/groupPage/schedule/worker_scheduleView.dart'; // ✅ 추가

class ScheduleRequestNav extends StatefulWidget {
  final String groupId;
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
    schedulePosts = [
      {
        'id': 'dummy-schedule-123',
        'title': '5월 근무 신청 (사장님 테스트용)',
        'description': '5월 근무 스케줄을 신청해주세요.',
        'createdAt': DateTime.now().toIso8601String(),
        'year': 2025,
        'month': 5,
      },
    ];
  }

  void _addSchedulePost(Map<String, dynamic> newPost) {
    setState(() {
      schedulePosts.add(newPost);
    });
  }

  void _handleCreatePost() async {
    final newPost = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const CreateSchedulePostPage()),
    );
    if (newPost != null) {
      newPost['id'] = 'dummy-${DateTime.now().millisecondsSinceEpoch}';
      _addSchedulePost(newPost);
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
              userRole: widget.userRole,
            );
          }).toList(),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => WorkerScheduleViewPage(
                        scheduleId: 'dummy-schedule-123',
                        userId: 'dummy-user-id',
                        year: 2025,
                        month: 5,
                      ),
                ),
              );
            },
            child: const Text('🔧 테스트용: 알바생 스케줄 보기 페이지로 이동'),
          ),
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
