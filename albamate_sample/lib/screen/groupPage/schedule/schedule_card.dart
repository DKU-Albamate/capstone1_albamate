import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'worker_scheduleView.dart';
import 'boss_scheduleView.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleCard extends StatelessWidget {
  final String title;
  final String description;
  final String createdAt;
  final String scheduleId;
  final int year;
  final int month;
  // TODO: ⚠️ 현재 userRole 임시 사용 중 (백엔드 ownerId 연동 시 제거 예정)
  final String userRole; // ✅ 역할 추가 ('사장님', '알바생')
  final String groupId;
  final VoidCallback? onScheduleConfirmed; // 추가

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
    required this.groupId,
    this.onScheduleConfirmed,              // 생성자에 추가
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
        onTap: () async {
          print('👀 전달된 역할: [$userRole]');
          if (userRole == '사장님') {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BossScheduleViewPage(
                  groupId: groupId,
                  scheduleId: scheduleId,
                  year: year,
                  month: month,
                ),
              ),
            );
            // 만약 하위 페이지에서 true를 반환했다면 콜백을 실행
            if (result == true) {
              print('result는 true, onScheduleConfirmed 호출');
              onScheduleConfirmed?.call();
            }
          } else if (userRole == '알바생') {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그인이 필요합니다.')),
              );
              return;
            }
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkerScheduleViewPage(
                  scheduleId: scheduleId,
                  userId: user.uid,
                  year: year,
                  month: month,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('올바르지 않은 역할입니다.')),
            );
          }
        }
      ),
    );
  }
}
