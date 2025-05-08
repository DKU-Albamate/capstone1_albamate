import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/groupPage/schedule/create_schedule.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_card.dart';

class ScheduleRequestTab extends StatefulWidget {
  final String groupId;

  const ScheduleRequestTab({super.key, required this.groupId});

  @override
  State<ScheduleRequestTab> createState() => _ScheduleRequestTabState();
}

class _ScheduleRequestTabState extends State<ScheduleRequestTab> {
  List<Map<String, String>> schedulePosts = [];

  void _addSchedulePost(Map<String, String> newPost) {
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
