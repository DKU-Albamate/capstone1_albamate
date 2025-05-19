import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// "알바생"이면 수정 불가

class GroupCalendarPage extends StatefulWidget {
  final String userRole;
  final String groupId;
  const GroupCalendarPage({required this.userRole, required this.groupId, super.key});

  @override
  _GroupCalendarPageState createState() => _GroupCalendarPageState();
}

class _GroupCalendarPageState extends State<GroupCalendarPage> {

  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Appointment>> _events = {};
  List<Appointment> _appointments = [];

  @override
  void initState() {
    // 이미 생성자에서 전달받았고 widget.userRole/widget.groupId로 직접 접근
    super.initState();
    // ⚠️ 아래 함수는 임시 주석처리 — 그룹 캘린더용 API가 필요함
    // _fetchAppointments();
  }

  int _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return int.parse('FF$hex', radix: 16);
  }

  @override
  Widget build(BuildContext context) {
    final int year = _focusedDay.year;
    final int month = _focusedDay.month;
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final daysInMonth =
    List.generate(lastDayOfMonth.day, (index) => DateTime(year, month, index + 1));


    return Scaffold(
      appBar: AppBar(
        title: Text("그룹 캘린더"),
        actions: widget.userRole == "사장님"
            ? [
          TextButton.icon( style: TextButton.styleFrom(
            backgroundColor: Color(0xFF006FFD),
          ),
            onPressed: () {
              // TODO: 스케줄 연동 기능 연결
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("스케줄 연동 기능은 준비 중입니다.")),
              );
            },
            icon: Icon(Icons.link, color: Colors.white),
            label: Text("연동", style: TextStyle(color: Colors.black)),

          ),
        ]
            : null,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () => setState(
                          () => _focusedDay = DateTime(year, month - 1)),
                ),
                Text("${year}년 ${month}월",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () => setState(
                          () => _focusedDay = DateTime(year, month + 1)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text("일", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("월", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("화", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("수", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("목", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("금", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("토", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Table(
              border: TableBorder.symmetric(
                inside: BorderSide(color: Colors.grey.shade300),
              ),
              columnWidths: const {
                0: FlexColumnWidth(), 1: FlexColumnWidth(), 2: FlexColumnWidth(),
                3: FlexColumnWidth(), 4: FlexColumnWidth(), 5: FlexColumnWidth(),
                6: FlexColumnWidth(),
              },
              children: _buildCalendarRows(daysInMonth),
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> _buildCalendarRows(List<DateTime> daysInMonth) {
    List<TableRow> rows = [];
    List<Widget> cells = [];
    int startWeekday = daysInMonth.first.weekday % 7;

    for (int i = 0; i < startWeekday; i++) {
      cells.add(Container(height: 80));
    }

    for (final date in daysInMonth) {
      final today = DateTime.now();
      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
      final events = _events[date] ?? [];

      cells.add(GestureDetector(
        onTap: () => _showDayDetailSheet(date),
        child: Container(
          padding: EdgeInsets.all(4),
          constraints: BoxConstraints(minHeight: 80 + 20.0 * events.length),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToday ? Colors.blue : null,
                ),
                alignment: Alignment.center,
                child: Text('${date.day}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : Colors.black)),
              ),
              ...events.take(5).map((e) => Container(
                height: 20,
                margin: EdgeInsets.only(top: 2),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: e.color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  e.subject,
                  style: TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              if (events.length > 5)
                Text('+${events.length - 5}',
                    style: TextStyle(fontSize: 10, color: Colors.grey))
            ],
          ),
        ),
      ));

      if (cells.length == 7) {
        rows.add(TableRow(children: List.from(cells)));
        cells.clear();
      }
    }

    if (cells.isNotEmpty) {
      while (cells.length < 7) {
        cells.add(Container(height: 80));
      }
      rows.add(TableRow(children: List.from(cells)));
    }

    return rows;
  }

  void _showDayDetailSheet(DateTime date) {
    final dayAppointments = _events[date] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Scaffold(
          appBar: AppBar(
            title: Text("${date.month}월 ${date.day}일 일정"),
            actions: [
              if (widget.userRole == "사장님")
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddDialog(date);
                  },
                ),
            ],
          ),
          body: ListView.builder(
            controller: scrollController,
            itemCount: dayAppointments.length,
            itemBuilder: (context, index) {
              final appt = dayAppointments[index];
              return Slidable(
                key: ValueKey(appt.notes ?? '${appt.subject}-$index'),
                endActionPane: widget.userRole == "사장님"
                    ? ActionPane(
                  motion: const ScrollMotion(),
                  extentRatio: 0.4,
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        Navigator.pop(context);
                        _showEditDialog(appt);
                      },
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue,
                      icon: Icons.edit,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    SlidableAction(
                      onPressed: (_) async {
                        // ⚠️ 여기에 그룹 일정 삭제용 DELETE API 연동 필요
                      },
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      icon: Icons.delete,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                )
                    : null,
                child: ListTile(
                  title: Text(appt.subject),
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: appt.color,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // _showAddDialog와 _showEditDialog는 이미 포함되어 있음

  void _showAddDialog(DateTime date) {
    String title = "";
    Color selectedColor = Color(0xFFFEE1E8);
    TimeOfDay start = TimeOfDay(hour: 9, minute: 0);
    TimeOfDay end = TimeOfDay(hour: 10, minute: 0);

    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("일정 추가", style: TextStyle(fontSize: 18)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  '#FEE1E8', '#F6EAC2', '#D3E5EF', '#D4F0C0',
                  '#FFF5BA', '#F8D1C1', '#E2DAF9', '#B2EBF2'
                ].map((hex) {
                  final color = Color(int.parse('FF${hex.substring(1)}', radix: 16));
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedColor = color),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == color ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              TextField(
                decoration: InputDecoration(labelText: '제목'),
                onChanged: (value) => title = value,
              ),
              ElevatedButton(
                child: Text("추가"),
                onPressed: () async {
                  // ⚠️ 여기에 그룹 일정 저장용 POST API 연동 필요
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Appointment appt) {
    String title = appt.subject;
    Color selectedColor = appt.color;
    TimeOfDay start = TimeOfDay.fromDateTime(appt.startTime);
    TimeOfDay end = TimeOfDay.fromDateTime(appt.endTime);

    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("일정 수정", style: TextStyle(fontSize: 18)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  '#FEE1E8', '#F6EAC2', '#D3E5EF', '#D4F0C0',
                  '#FFF5BA', '#F8D1C1', '#E2DAF9', '#B2EBF2'
                ].map((hex) {
                  final color = Color(int.parse('FF${hex.substring(1)}', radix: 16));
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedColor = color),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == color ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              TextField(
                controller: TextEditingController(text: title),
                decoration: InputDecoration(labelText: '제목'),
                onChanged: (value) => title = value,
              ),
              ElevatedButton(
                child: Text("수정"),
                onPressed: () async {
                  // ⚠️ 여기에 그룹 일정 수정용 PATCH API 연동 필요
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Appointment {
  final DateTime startTime;
  final DateTime endTime;
  final String subject;
  final Color color;
  final String? notes;

  Appointment({
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.color,
    this.notes,
  });
}
