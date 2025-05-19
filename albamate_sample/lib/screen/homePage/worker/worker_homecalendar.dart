import 'package:flutter/material.dart';
import '/component/home_navigation_worker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

//직원 캘린더
class WorkerHomecalendar extends StatefulWidget {
  const WorkerHomecalendar({super.key});

  @override
  _WorkerHomecalendarState createState() => _WorkerHomecalendarState();
}

class _WorkerHomecalendarState extends State<WorkerHomecalendar> {
  bool _isMounted = false;
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Appointment>> _events = {};
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _fetchAppointments();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final response = await http.get(Uri.parse(
        'https://backend-vgbf.onrender.com/appointments?user_uid=$uid'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      final fetched = jsonList
          .where((item) =>
      item['start_time'] != null &&
          item['end_time'] != null &&
          DateTime.parse(item['start_time']).isBefore(
              DateTime.parse(item['end_time'])))
          .map((item) => Appointment(
        startTime: DateTime.parse(item['start_time']),
        endTime: DateTime.parse(item['end_time']),
        subject: item['title'],
        color: Color(_hexToColor(item['color'] ?? '#FF9900')),
        notes: item['id'],
      ))
          .toList();

      Map<DateTime, List<Appointment>> grouped = {};
      for (var appt in fetched) {
        final date = DateTime(
            appt.startTime.year, appt.startTime.month, appt.startTime.day);
        if (!grouped.containsKey(date)) grouped[date] = [];
        grouped[date]!.add(appt);
      }

      if (_isMounted) {
        setState(() {
          _appointments = fetched;
          _events = grouped;
        });
      }
    }
  }

  int _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return int.parse('FF$hex', radix: 16);
  }

  @override
  Widget build(BuildContext context) {
    final int year = _focusedDay.year;
    final int month = _focusedDay.month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    final daysInMonth =
    List.generate(lastDayOfMonth.day, (index) => DateTime(year, month, index + 1));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("캘린더"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: () =>
                        setState(() => _focusedDay = DateTime(year, month - 1)),
                  ),
                  Text("${year}년 ${month}월",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: () =>
                        setState(() => _focusedDay = DateTime(year, month + 1)),
                  ),
                ],
              ),
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
      bottomNavigationBar: HomeNavigationWorker(currentIndex: 1),
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
      final isToday =
          date.year == today.year && date.month == today.month && date.day == today.day;
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
              ...events.take(10).map((e) => Container(
                height: 20,
                width: double.infinity,
                margin: EdgeInsets.only(top: 2),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: e.color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  e.subject,
                  style: TextStyle(fontSize: 10, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              if (events.length > 10)
                Text('+${events.length - 10}',
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
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
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  extentRatio: 0.4,
                  children: [
                    SlidableAction(
                      flex: 1,
                      onPressed: (_) {
                        Navigator.pop(context);
                        _showEditDialog(appt);
                      },
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue,
                      icon: Icons.edit_outlined,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    SlidableAction(
                      flex: 1,
                      onPressed: (_) async {
                        final response = await http.delete(
                          Uri.parse('https://backend-vgbf.onrender.com/appointments/${appt.notes}'),
                        );
                        if (response.statusCode == 204) {
                          setState(() => _appointments.remove(appt));
                          _fetchAppointments();
                        }
                        Navigator.pop(context);
                      },
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      icon: Icons.delete_outline,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: appt.color,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  title: Text(
                    appt.subject,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAddDialog(DateTime selectedDate) {
    String title = "";
    Color selectedColor = Color(0xFFFEE1E8);
    TimeOfDay start = TimeOfDay(hour: selectedDate.hour, minute: 0);
    TimeOfDay end = TimeOfDay(hour: (selectedDate.hour + 1) % 24, minute: 0);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("일정 추가", style: TextStyle(fontSize: 18)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '#FEE1E8', '#F6EAC2', '#D3E5EF', '#D4F0C0', '#FFF5BA', '#F8D1C1', '#E2DAF9', '#B2EBF2'
                    ].map((hex) {
                      final color = Color(int.parse('FF' + hex.substring(1), radix: 16));
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
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: '제목'),
                    onChanged: (value) => title = value,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    child: Text("추가"),
                    onPressed: () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) return;

                      final newAppointment = Appointment(
                        startTime: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, start.hour, start.minute),
                        endTime: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, end.hour, end.minute),
                        subject: title,
                        color: selectedColor,
                      );

                      final response = await http.post(
                        Uri.parse('https://backend-vgbf.onrender.com/appointments'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'user_uid': uid,
                          'title': title,
                          'start_time': newAppointment.startTime.toIso8601String(),
                          'end_time': newAppointment.endTime.toIso8601String(),
                          'color': '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                        }),
                      );

                      if (response.statusCode == 201) {
                        Navigator.pop(context);
                        _fetchAppointments();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditDialog(Appointment oldAppointment) {
    String title = oldAppointment.subject;
    Color selectedColor = oldAppointment.color;
    TimeOfDay start = TimeOfDay.fromDateTime(oldAppointment.startTime);
    TimeOfDay end = TimeOfDay.fromDateTime(oldAppointment.endTime);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("일정 수정", style: TextStyle(fontSize: 18)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '#FEE1E8', '#F6EAC2', '#D3E5EF', '#D4F0C0', '#FFF5BA', '#F8D1C1', '#E2DAF9', '#B2EBF2'
                    ].map((hex) {
                      final color = Color(int.parse('FF' + hex.substring(1), radix: 16));
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
                  SizedBox(height: 10),
                  TextField(
                    controller: TextEditingController(text: title),
                    decoration: InputDecoration(labelText: '제목'),
                    onChanged: (value) => title = value,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    child: Text("수정"),
                    onPressed: () async {
                      final updated = Appointment(
                        startTime: oldAppointment.startTime,
                        endTime: oldAppointment.endTime,
                        subject: title,
                        color: selectedColor,
                        notes: oldAppointment.notes,
                      );

                      final response = await http.patch(
                        Uri.parse('https://backend-vgbf.onrender.com/appointments/${oldAppointment.notes}'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'title': updated.subject,
                          'start_time': updated.startTime.toIso8601String(),
                          'end_time': updated.endTime.toIso8601String(),
                          'color': '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                        }),
                      );

                      if (response.statusCode == 200) {
                        setState(() {
                          final index = _appointments.indexWhere((a) => a.notes == oldAppointment.notes);
                          if (index != -1) {
                            _appointments[index] = updated;
                            final dateKey = DateTime(updated.startTime.year, updated.startTime.month, updated.startTime.day);
                            _events[dateKey] = _appointments.where((a) =>
                            a.startTime.year == dateKey.year &&
                                a.startTime.month == dateKey.month &&
                                a.startTime.day == dateKey.day).toList();
                          }
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
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
