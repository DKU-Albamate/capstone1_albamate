import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:albamate_sample/screen/groupPage/schedule/schdule_confirm_detail.dart';

class ScheduleConfirmNav extends StatefulWidget {
  final String groupId;

  const ScheduleConfirmNav({super.key, required this.groupId});

  static final List<Map<String, dynamic>> confirmedSchedules = [];

  static void addConfirmedSchedule(Map<String, dynamic> schedule) {
    confirmedSchedules.add(schedule);
  }

  @override
  State<ScheduleConfirmNav> createState() => _ScheduleConfirmNavState();
}

class _ScheduleConfirmNavState extends State<ScheduleConfirmNav> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: ScheduleConfirmNav.confirmedSchedules.length,
      itemBuilder: (context, index) {
        final schedule = ScheduleConfirmNav.confirmedSchedules[index];
        final createdAt = schedule['createdAt'];
        final createdAtFormatted = DateFormat('yyyy-MM-dd').format(
          createdAt is DateTime
              ? createdAt
              : DateTime.tryParse(createdAt.toString()) ?? DateTime.now(),
        );

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: ListTile(
            title: Text(schedule['title'] ?? 'No Title'),
            subtitle: Text('작성일: $createdAtFormatted'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ScheduleConfirmDetailPage(
                        title: schedule['title'] ?? '',
                        createdAt: createdAt.toString(),
                        scheduleMapJson:
                            schedule['scheduleMap'] is String
                                ? schedule['scheduleMap']
                                : jsonEncode(
                                  schedule['scheduleMap'],
                                ), // ✅ 이 부분 수정
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
