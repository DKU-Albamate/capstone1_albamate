import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config/api.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schdule_confirm_detail.dart';

class ScheduleConfirmNav extends StatefulWidget {
  final String groupId;

  const ScheduleConfirmNav({super.key, required this.groupId});

  @override
  State<ScheduleConfirmNav> createState() => _ScheduleConfirmNavState();
}

class _ScheduleConfirmNavState extends State<ScheduleConfirmNav> {
  List<Map<String, dynamic>> confirmedSchedules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchConfirmedSchedules();
  }

  Future<void> fetchConfirmedSchedules() async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    if (idToken == null) {
      print('❗ 사용자 인증 토큰 없음');
      return;
    }

    final response = await http.get(
      Uri.parse('$BACKEND_SCHEDULE_BASE/api/schedules/confirmed?groupId=${widget.groupId}'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() {
        confirmedSchedules = List<Map<String, dynamic>>.from(decoded['data']);
        isLoading = false;
      });
    } else {
      print('❌ 서버 응답 실패: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (confirmedSchedules.isEmpty) {
      return const Center(child: Text('확정된 스케줄이 없습니다.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: confirmedSchedules.length,
      itemBuilder: (context, index) {
        final schedule = confirmedSchedules[index];
        final confirmedAt = schedule['confirmedAt'];
        final confirmedAtFormatted = DateFormat('yyyy-MM-dd').format(
          confirmedAt is DateTime
              ? confirmedAt
              : DateTime.tryParse(confirmedAt.toString()) ?? DateTime.now(),
        );

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: ListTile(
            title: Text(schedule['confirmedTitle'] ?? '제목 없음'),
            subtitle: Text('확정일: $confirmedAtFormatted'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScheduleConfirmDetailPage(
                    title: schedule['confirmedTitle'] ?? '',
                    createdAt: confirmedAt.toString(),
                    scheduleMapJson: jsonEncode(schedule['assignments']),
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
