import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/groupPage/schedule/create_schedule.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_card.dart';
import 'package:albamate_sample/screen/groupPage/schedule/boss_scheduleView.dart';
import 'package:albamate_sample/screen/groupPage/schedule/worker_scheduleView.dart';

class ScheduleRequestNav extends StatefulWidget {
  final String groupId;

  const ScheduleRequestNav({super.key, required this.groupId});

  @override
  State<ScheduleRequestNav> createState() => _ScheduleRequestNavState();
}

class _ScheduleRequestNavState extends State<ScheduleRequestNav> {
  List<Map<String, String>> schedulePosts = [];

  void _addSchedulePost(Map<String, String> newPost) {
    setState(() {
      schedulePosts.add(newPost);
    });
  }

  void _showRoleDialog(String scheduleId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('역할 선택'),
            content: const Text('어떤 역할로 이 스케줄을 보시겠어요?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              BossScheduleViewPage(scheduleId: scheduleId),
                    ),
                  );
                },
                child: const Text('사장님 뷰'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => WorkerScheduleViewPage(
                            scheduleId: scheduleId,
                            userId: 'dummy-user-id',
                          ),
                    ),
                  );
                },
                child: const Text('알바생 뷰'),
              ),
            ],
          ),
    );
  }

  void _handleCreatePost() async {
    final newPost = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const CreateSchedulePostPage()),
    );
    if (newPost != null) _addSchedulePost(newPost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children:
            schedulePosts.map((post) {
              return GestureDetector(
                onTap: () => _showRoleDialog(post['id'] ?? 'dummy-schedule-id'),
                child: ScheduleCard(
                  title: post['title'] ?? '',
                  description: post['description'] ?? '',
                  createdAt: post['createdAt'] ?? '',
                ),
              );
            }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleCreatePost,
        backgroundColor: Colors.blue,
        label: const Text('CREATE'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
