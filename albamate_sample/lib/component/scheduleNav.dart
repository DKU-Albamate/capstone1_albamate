import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_card.dart';

class ScheduleRequestTab extends StatefulWidget {
  final String groupId;

  const ScheduleRequestTab({super.key, required this.groupId});

  @override
  State<ScheduleRequestTab> createState() => _ScheduleRequestTabState();
}

class _ScheduleRequestTabState extends State<ScheduleRequestTab> {
  List<Map<String, dynamic>> schedulePosts = [];

  void _addSchedulePost(Map<String, dynamic> newPost) {
    setState(() {
      schedulePosts.add(newPost);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ...schedulePosts.map(
          (post) => ScheduleCard(
            title: post['title'] ?? '',
            description: post['description'] ?? '',
            createdAt: post['createdAt'] ?? '',
            scheduleId: post['id'] ?? 'dummy-schedule-id',
            year: post['year'],
            month: post['month'],
            userRole: '',
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 💡 FloatingActionButton은 Home에서 관리, 이 페이지는 내용만 렌더링
  }
}
