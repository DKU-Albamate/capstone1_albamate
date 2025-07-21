import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'groupCalendar.dart';
import 'group_imageProcessing.dart'; // Schedule 클래스 정의
import 'package:albamate_sample/component/groupHome_navigation.dart';

class GroupImageParseViewPage extends StatelessWidget {
  final File imageFile;
  final List<Schedule> schedules;
  final String userRole;
  final String groupId;

  GroupImageParseViewPage({
    super.key,
    required this.imageFile,
    required this.schedules,
    required this.userRole,
    required this.groupId,
  });

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  final _dateFmt = DateFormat('M월 d일 (E)', 'ko');

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    // 이름 기준 그룹화
    final Map<String, List<Schedule>> schedulesByName = {};
    for (final s in schedules) {
      schedulesByName.putIfAbsent(s.name, () => []).add(s);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('스케줄 추출 결과')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 이미지 영역
            Container(
              height: h * 0.45,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InteractiveViewer(
                  child: Image.file(imageFile, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '이름별 추출된 일정',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 이름별 일정 리스트
            Expanded(
              child: schedulesByName.isEmpty
                  ? const Center(
                child: Text(
                  '추출된 일정이 없습니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView(
                children: schedulesByName.entries.map((entry) {
                  final name = entry.key;
                  final personSchedules = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        '👤 $name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...personSchedules.map((s) => ListTile(
                        leading: const Icon(Icons.event_note),
                        title: Text(
                          '${_fmt(s.start)} ~ ${_fmt(s.end)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${_dateFmt.format(s.date)}  |  ${s.title}',
                          softWrap: true,
                        ),
                        isThreeLine: true,
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupNav(
                      groupId: groupId,
                      userRole: userRole,
                      initialIndex: 3,
                    ),
                  ),
                      (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006FFD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                const Text('캘린더로 이동', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
