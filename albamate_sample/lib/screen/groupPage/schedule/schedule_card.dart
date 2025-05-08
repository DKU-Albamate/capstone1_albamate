import 'package:flutter/material.dart';
import 'worker_scheduleView.dart';
import 'boss_scheduleView.dart';

class ScheduleCard extends StatelessWidget {
  final String title;
  final String description;
  final String createdAt;

  const ScheduleCard({
    super.key,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Text('생성일: $createdAt', style: const TextStyle(fontSize: 12)),
          ],
        ),
        onTap: () {
          // TODO: 백엔드 연동 전까지 역할 선택 다이얼로그로 대체
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
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
                              (context) => BossScheduleViewPage(
                                scheduleId: 'dummy-schedule-id',
                              ),
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
                                scheduleId: 'dummy-schedule-id',
                                userId: 'dummy-user-id',
                              ),
                        ),
                      );
                    },
                    child: const Text('알바생 뷰'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
