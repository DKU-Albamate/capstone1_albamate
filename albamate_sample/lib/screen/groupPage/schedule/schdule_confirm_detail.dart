import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';

class ScheduleConfirmDetailPage extends StatefulWidget {
  final String title;
  final String createdAt;
  final String scheduleMapJson;

  const ScheduleConfirmDetailPage({
    super.key,
    required this.title,
    required this.createdAt,
    required this.scheduleMapJson,
  });

  @override
  State<ScheduleConfirmDetailPage> createState() =>
      _ScheduleConfirmDetailPageState();
}

class _ScheduleConfirmDetailPageState extends State<ScheduleConfirmDetailPage> {
  late Map<DateTime, List<String>> _events;
  bool isChecked = false; // 체크박스 상태 관리
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _parseSchedule();
  }

  void _parseSchedule() {
    final Map<String, dynamic> scheduleMap = json.decode(
      widget.scheduleMapJson,
    );
    final parsedMap = scheduleMap.map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );

    _events = {};
    parsedMap.forEach((dateStr, users) {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        _events[DateTime(date.year, date.month, date.day)] = users;
      }
    });
  }

  void _updateCheckmark(bool selected) {
    // 체크박스 상태 업데이트 시 처리할 로직
    print('체크 상태: $selected');
    // 이후 서버 업데이트 등의 로직 추가 가능
  }

  @override
  Widget build(BuildContext context) {
    final int year = _focusedDay.year;
    final int month = _focusedDay.month;

    final daysInMonth = List.generate(
      DateTime(year, month + 1, 0).day,
      (index) => DateTime(year, month, index + 1),
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                '생성일: ${widget.createdAt.split("T")[0]}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            // 커스텀 달력 Table UI - BossHomecalendar 스타일에 맞춤
            Table(
              border: TableBorder(
                top: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
                horizontalInside: BorderSide(color: Colors.grey.shade300),
              ),
              columnWidths: const {
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
                4: FlexColumnWidth(),
                5: FlexColumnWidth(),
                6: FlexColumnWidth(),
              },
              children: _buildCalendarRows(daysInMonth),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            children: [
              MSHCheckbox(
                size: 22,
                value: isChecked,
                colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                  checkedColor: Colors.blue,
                ),
                style: MSHCheckboxStyle.fillScaleColor,
                onChanged: (selected) {
                  setState(() {
                    isChecked = selected;
                  });
                  _updateCheckmark(selected);
                },
              ),
              SizedBox(width: 8),
              Text('확인', style: TextStyle(color: Colors.grey[800])),
            ],
          ),
        ),
      ),
    );
  }

  // 달력 테이블에 표시될 각 날짜 쉘 생성 - BossHomecalendar 스타일 적용
  List<TableRow> _buildCalendarRows(List<DateTime> daysInMonth) {
    List<TableRow> rows = [];
    List<Widget> cells = [];
    int startWeekday = daysInMonth.first.weekday % 7; //일욜 시작

    for (int i = 0; i < startWeekday; i++) {
      cells.add(Container(height: 80));
    }

    for (final date in daysInMonth) {
      final today = DateTime.now();
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final events = _events[date] ?? [];

      cells.add(
        Container(
          padding: EdgeInsets.all(4),
          constraints: BoxConstraints(minHeight: 80 + 20.0 * events.length),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 숫자, 오늘 강조
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToday ? Color(0xFF006FFD) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : Colors.black,
                  ),
                ),
              ),
              // 일정 리스트 미리보기
              ...events
                  .take(10)
                  .map(
                    (e) => Container(
                      height: 20,
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 2),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        e,
                        style: TextStyle(fontSize: 10, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              // 10개 이상 쌓이면 +n개 로 표시
              if (events.length > 10)
                Text(
                  '+${events.length - 10}',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ),
      );

      // 한 줄 완성 시 테이블에 추가
      if (cells.length == 7) {
        rows.add(TableRow(children: List.from(cells)));
        cells.clear();
      }
    }

    // 마지막 주 빈 셀 보완
    if (cells.isNotEmpty) {
      while (cells.length < 7) {
        cells.add(Container(height: 80));
      }
      rows.add(TableRow(children: List.from(cells)));
    }

    return rows;
  }
}
