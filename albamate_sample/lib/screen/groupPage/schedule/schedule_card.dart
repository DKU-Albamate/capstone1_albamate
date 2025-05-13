import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'worker_scheduleView.dart';
import 'boss_scheduleView.dart';

class ScheduleCard extends StatelessWidget {
  final String title;
  final String description;
  final String createdAt;
  final String scheduleId;
  final int year;
  final int month;
  // TODO: ⚠️ 현재 userRole 임시 사용 중 (백엔드 ownerId 연동 시 제거 예정)
  final String userRole; // ✅ 역할 추가 ('사장님', '알바생')

  const ScheduleCard({
    super.key,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.scheduleId,
    required this.year,
    required this.month,
    // TODO: ⚠️ 현재 userRole 임시 사용 중 (백엔드 ownerId 연동 시 제거 예정)
    required this.userRole, // ✅ 역할 받기
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
            Text(
              '생성일: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(createdAt))}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          if (userRole == '사장님') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BossScheduleViewPage(
                      scheduleId: scheduleId,
                      year: year,
                      month: month,
                    ),
              ),
            );
          } else if (userRole == '알바생') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => WorkerScheduleViewPage(
                      scheduleId: scheduleId,
                      userId: 'dummy-user-id', // ✅ 나중에 실제 userId 전달
                      year: year,
                      month: month,
                    ),
              ),
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('올바르지 않은 역할입니다.')));
          }
        },
      ),
    );
  }
}
