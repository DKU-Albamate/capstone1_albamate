import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config/api.dart';

class WorkerScheduleViewPage extends StatefulWidget {
  final String scheduleId;
  final String userId; // 사용자 ID, 백엔드 연동 시 필요
  final int year;
  final int month;

  const WorkerScheduleViewPage({
    super.key,
    required this.scheduleId,
    required this.userId,
    required this.year,
    required this.month,
  });

  @override
  State<WorkerScheduleViewPage> createState() => _WorkerScheduleViewPageState();
}

class _WorkerScheduleViewPageState extends State<WorkerScheduleViewPage> {
  Set<DateTime> unavailableDates = {}; // 날짜 선택 기록
  late DateTime fixedMonth;

  @override
  void initState() {
    super.initState();
    fixedMonth = DateTime(widget.year, widget.month);
    fetchUnavailableDates(); // 🔹 기존 불가 날짜 불러오기
  }

  Future<void> fetchUnavailableDates() async {
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final url = Uri.parse('$BACKEND_SCHEDULE_BASE/api/schedules/${widget.scheduleId}/unavailable');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> dates = jsonDecode(response.body)['data'];

        setState(() {
          unavailableDates = dates
              .map((dateStr) => DateTime.parse(dateStr))
              .toSet();
        });
      } else {
        print('❌ 날짜 불러오기 실패: ${response.body}');
      }
    } catch (e) {
      print('❌ 오류 발생: $e');
    }
  }

  void toggleDate(DateTime date) {
    setState(() {
      if (unavailableDates.contains(date)) {
        unavailableDates.remove(date);
      } else {
        unavailableDates.add(date);
      }
    });
  }

  void saveSchedule() async {
    final List<String> formattedDates = unavailableDates
        .map((d) => DateFormat('yyyy-MM-dd').format(d))
        .toList();

    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final url = Uri.parse('$BACKEND_SCHEDULE_BASE/api/schedules/${widget.scheduleId}/unavailable');

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'dates': formattedDates}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장되었습니다!')),
        );
      } else {
        print('❌ 저장 실패: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('❌ 저장 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  List<Widget> buildCalendarDays() {
    final firstDayOfMonth = DateTime(fixedMonth.year, fixedMonth.month, 1);
    final lastDayOfMonth = DateTime(fixedMonth.year, fixedMonth.month + 1, 0);

    // 날짜 시작 요일 계산 (0: 일요일, 1: 월요일, ..., 6: 토요일)
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    // 첫 주의 빈 공간도 동일한 크기의 Container를 사용하여 정렬 맞추기
    for (int i = 0; i < firstWeekday; i++) {
      currentRow.add(
        Container(width: 40, height: 40, margin: const EdgeInsets.all(2)),
      );
    }

    for (int day = 1; day <= totalDays; day++) {
      final currentDate = DateTime(fixedMonth.year, fixedMonth.month, day);
      final isSelected = unavailableDates.contains(currentDate);

      currentRow.add(
        GestureDetector(
          onTap: () => toggleDate(currentDate),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: isSelected ? Colors.red : Colors.grey),
              borderRadius: BorderRadius.circular(6),
              color: isSelected ? Colors.red[100] : Colors.transparent,
            ),
            child: Text('$day'),
          ),
        ),
      );

      if (currentRow.length == 7) {
        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: currentRow,
          ),
        );
        currentRow = [];
      }
    }

    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(
          Container(width: 40, height: 40, margin: const EdgeInsets.all(2)),
        );
      }
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: currentRow,
        ),
      );
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final monthText = DateFormat('yyyy. MM').format(fixedMonth);

    return Scaffold(
      appBar: AppBar(title: const Text('내 스케줄 신청')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '날짜를 선택해주세요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                monthText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 각 요일을 담을 Container를 생성하여 일관된 크기 유지
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: const Text('일'),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: const Text('월'),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: const Text('화'),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: const Text('수'),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: const Text('목'),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: const Text('금'),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: const Text('토'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...buildCalendarDays(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveSchedule,
                child: const Text('저장하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
