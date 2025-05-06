import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '/component/home_navigation_boss.dart';
// 벡엔드 필요한 패키지 추가
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart'; // user UID 가져오기 위해

class BossHomecalendar extends StatefulWidget {
  const BossHomecalendar({super.key});

  @override
  _BossHomecalendarState createState() => _BossHomecalendarState();
}

class _BossHomecalendarState extends State<BossHomecalendar> {
  CalendarView _calendarView = CalendarView.month;
  List<Appointment> _appointments = [];
  CalendarController _controller = CalendarController();

  late int _displayYear;
  late int _displayMonth;

  @override
  void initState() {
    super.initState();
    _fetchAppointments(); // 서버에서 일정 불러오기
    final now = DateTime.now();
    _controller.displayDate = now;
    _displayYear = now.year;
    _displayMonth = now.month;
  }
  Future<void> _fetchAppointments() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final response = await http.get(Uri.parse(
      'https://backend-vgbf.onrender.com/appointments?user_uid=$uid',
    ));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      final List<Appointment> fetched = jsonList
          .where((item) =>
      item['start_time'] != null &&
          item['end_time'] != null &&
          DateTime.parse(item['start_time'])
              .isBefore(DateTime.parse(item['end_time'])))
          .map((item) => Appointment(
        startTime: DateTime.parse(item['start_time']),
        endTime: DateTime.parse(item['end_time']),
        subject: item['title'],
        color: Color(_hexToColor(item['color'] ?? '#FF9900')),
        notes: item['id'],
      ))
      .toList();

      setState(() => _appointments = fetched);
    }
  }

  int _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return int.parse('FF$hex', radix: 16);
  }

  @override
  Widget build(BuildContext context) {
    final String yearMonth = "$_displayYear년 $_displayMonth월";

    return Scaffold(
      appBar: AppBar(
        title: Text("캘린더"),
        actions: [
          PopupMenuButton<CalendarView>(
            onSelected: (CalendarView value) {
              setState(() {
                _calendarView = value;
              });
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: CalendarView.day, child: Text("일간 보기")),
                  PopupMenuItem(value: CalendarView.week, child: Text("주간 보기")),
                  PopupMenuItem(
                    value: CalendarView.month,
                    child: Text("월간 보기"),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: _goToPreviousMonth,
                  icon: Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _showMonthYearPicker,
                    child: Center(
                      child: Text(
                        yearMonth,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _goToNextMonth,
                  icon: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          Expanded(
            child: SfCalendar(
              controller: _controller,
              view: _calendarView,
              firstDayOfWeek: 1,
              dataSource: MeetingDataSource(_appointments),
              todayHighlightColor: Colors.red,
              cellBorderColor: Colors.transparent,
              headerHeight: 0,
              showDatePickerButton: false,
              monthCellBuilder: (
                BuildContext context,
                MonthCellDetails details,
              ) {
                final bool isToday =
                    details.date.year == DateTime.now().year &&
                    details.date.month == DateTime.now().month &&
                    details.date.day == DateTime.now().day;

                return Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(top: 4), // 텍스트 상단 여백 줄이기
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isToday)
                        Container(
                          width: 20, // ✅ 원 크기 조절
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Text(
                        '${details.date.day}',
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
              onTap: (details) {
                if (details.date != null) {
                  _showDayDetailSheet(details.date!);
                }
              },
              monthViewSettings: MonthViewSettings(
                showTrailingAndLeadingDates: false,
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeNavigationBoss(currentIndex: 1),
    );
  }

  void _goToPreviousMonth() {
    final current = _controller.displayDate ?? DateTime.now();
    final prev = DateTime(current.year, current.month - 1);
    setState(() {
      _controller.displayDate = prev;
      _displayYear = prev.year;
      _displayMonth = prev.month;
    });
  }

  void _goToNextMonth() {
    final current = _controller.displayDate ?? DateTime.now();
    final next = DateTime(current.year, current.month + 1);
    setState(() {
      _controller.displayDate = next;
      _displayYear = next.year;
      _displayMonth = next.month;
    });
  }

  void _showMonthYearPicker() async {
    int tempYear = _displayYear;
    int tempMonth = _displayMonth;

    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              height: 220,
              child: Column(
                children: [
                  Text("년도 / 월 선택", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<int>(
                        value: tempYear,
                        items:
                            List.generate(10, (index) => 2020 + index)
                                .map(
                                  (year) => DropdownMenuItem(
                                    value: year,
                                    child: Text("$year년"),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => tempYear = value);
                            setState(() => _displayYear = value);
                          }
                        },
                      ),
                      SizedBox(width: 16),
                      DropdownButton<int>(
                        value: tempMonth,
                        items:
                            List.generate(12, (index) => index + 1)
                                .map(
                                  (month) => DropdownMenuItem(
                                    value: month,
                                    child: Text("$month월"),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => tempMonth = value);
                            setState(() => _displayMonth = value);
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _controller.displayDate = DateTime(tempYear, tempMonth);
                      });
                      Navigator.pop(context);
                    },
                    child: Text("이동하기"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDayDetailSheet(DateTime date) {
    final dayAppointments =
        _appointments
            .where(
              (a) =>
                  a.startTime.year == date.year &&
                  a.startTime.month == date.month &&
                  a.startTime.day == date.day,
            )
            .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            expand: false,
            builder:
                (context, scrollController) => Scaffold(
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
                      return ListTile(
                        title: Text(appt.subject),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditDialog(appt);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final response = await http.delete(Uri.parse('https://backend-vgbf.onrender.com/appointments/${appt.notes}'));
                                if (response.statusCode == 204) {
                                  setState(() => _appointments.remove(appt));
                                }
                                Navigator.pop(context);
                                _showDayDetailSheet(date);
                              },
                            ),
                          ],
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
    TimeOfDay start = TimeOfDay(hour: selectedDate.hour, minute: 0);
    TimeOfDay end = TimeOfDay(hour: (selectedDate.hour + 1) % 24, minute: 0);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("일정 추가", style: TextStyle(fontSize: 18)),
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
                    startTime: DateTime(
                      selectedDate.year, selectedDate.month, selectedDate.day, start.hour, start.minute,
                    ),
                    endTime: DateTime(
                      selectedDate.year, selectedDate.month, selectedDate.day, end.hour, end.minute,
                    ),
                    subject: title,
                    color: Colors.orange,
                  );
                  final response = await http.post(
                    Uri.parse('https://backend-vgbf.onrender.com/appointments'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'user_uid': uid,
                      'title': title,
                      'start_time': newAppointment.startTime.toIso8601String(),
                      'end_time': newAppointment.endTime.toIso8601String(),
                      'color': '#FF9900',
                    }),
                  );

                  if (response.statusCode == 201) {
                    final json = jsonDecode(response.body);
                    final id = json[0]['id']; // ✅ 리스트에서 첫 번째 요소의 id 꺼냄

                    final newAppointment = Appointment(
                      startTime: DateTime(
                        selectedDate.year, selectedDate.month, selectedDate.day, start.hour, start.minute,
                      ),
                      endTime: DateTime(
                        selectedDate.year, selectedDate.month, selectedDate.day, end.hour, end.minute,
                      ),
                      subject: title,
                      color: Colors.orange,
                      notes: id, // ✅ 이거 꼭 저장해야 나중에 수정/삭제 가능
                    );

                    setState(() => _appointments.add(newAppointment));
                    Navigator.pop(context);
                  }

                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(Appointment oldAppointment) {
    String title = oldAppointment.subject;
    TimeOfDay start = TimeOfDay.fromDateTime(oldAppointment.startTime);
    TimeOfDay end = TimeOfDay.fromDateTime(oldAppointment.endTime);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("일정 수정", style: TextStyle(fontSize: 18)),
              TextField(
                controller: TextEditingController(text: title),
                decoration: InputDecoration(labelText: '제목'),
                onChanged: (value) => title = value,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text("수정"),
                onPressed: () async {
                  final index = _appointments.indexOf(oldAppointment);
                  if (index == -1) return;

                  final updated = Appointment(
                    startTime: DateTime(
                      oldAppointment.startTime.year,
                      oldAppointment.startTime.month,
                      oldAppointment.startTime.day,
                      start.hour,
                      start.minute,
                    ),
                    endTime: DateTime(
                      oldAppointment.endTime.year,
                      oldAppointment.endTime.month,
                      oldAppointment.endTime.day,
                      end.hour,
                      end.minute,
                    ),
                    subject: title,
                    color: oldAppointment.color,
                    notes: oldAppointment.notes,
                  );

                  final response = await http.patch(
                    Uri.parse('https://backend-vgbf.onrender.com/appointments/${oldAppointment.notes}'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'title': updated.subject,
                      'start_time': updated.startTime.toIso8601String(),
                      'end_time': updated.endTime.toIso8601String(),
                      'color': '#FF9900',
                    }),
                  );

                  if (response.statusCode == 200) {
                    final index = _appointments.indexOf(oldAppointment);
                    if (index != -1) {
                      setState(() => _appointments[index] = updated);
                    }
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Appointment> getAppointments() {
    return [
      Appointment(
        startTime: DateTime.now().add(Duration(hours: 2)),
        endTime: DateTime.now().add(Duration(hours: 3)),
        subject: '회의',
        color: Colors.blue,
      ),
      Appointment(
        startTime: DateTime.now().add(Duration(days: 1, hours: 4)),
        endTime: DateTime.now().add(Duration(days: 1, hours: 5)),
        subject: '운동',
        color: Colors.green,
      ),
    ];
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}

// 블록 위치 수정 
// 블록 크기 수정
// 블록 색깔 선택 가능하게 수정
// 블록 수정 및 삭제 시 안내메시지 추가 
