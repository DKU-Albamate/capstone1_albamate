import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  void saveSchedule() {
    // TODO: 이 데이터를 백엔드로 POST 또는 PUT 요청 보내기
    print(
      "불가 날짜 저장: ${unavailableDates.map((d) => DateFormat('yyyy-MM-dd').format(d)).toList()}",
    );
  }

  List<Widget> buildCalendarDays() {
    final firstDayOfMonth = DateTime(fixedMonth.year, fixedMonth.month, 1);
    final lastDayOfMonth = DateTime(fixedMonth.year, fixedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    for (int i = 0; i < firstWeekday; i++) {
      currentRow.add(const SizedBox(width: 40, height: 40));
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
        currentRow.add(const SizedBox(width: 40, height: 40));
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('일'),
                Text('월'),
                Text('화'),
                Text('수'),
                Text('목'),
                Text('금'),
                Text('토'),
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
