import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class GroupCalendarPage extends StatefulWidget {
  final String groupId;
  const GroupCalendarPage({super.key, required this.groupId});

  @override
  _GroupCalendarPageState createState() => _GroupCalendarPageState();
}

class _GroupCalendarPageState extends State<GroupCalendarPage> {
  CalendarView _calendarView = CalendarView.month;
  List<Appointment> _appointments = []; // TODO: groupId 기준 일정 목록으로 대체 필요
  CalendarController _controller = CalendarController();

  late int _displayYear;
  late int _displayMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _controller.displayDate = now;
    _displayYear = now.year;
    _displayMonth = now.month;
  }

  @override
  Widget build(BuildContext context) {
    final String yearMonth = "$_displayYear년 $_displayMonth월";

    return Scaffold(
      appBar: AppBar(
        title: const Text("그룹 캘린더"),
        actions: [
          PopupMenuButton<CalendarView>(
            onSelected: (CalendarView value) {
              setState(() {
                _calendarView = value;
              });
            },
            itemBuilder:
                (context) => const [
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
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _showMonthYearPicker,
                    child: Center(
                      child: Text(
                        yearMonth,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _goToNextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          Expanded(
            child: SfCalendar(
              controller: _controller,
              view: _calendarView,
              dataSource: MeetingDataSource(_appointments),
              firstDayOfWeek: 1,
              todayHighlightColor: Colors.red,
              cellBorderColor: Colors.transparent,
              headerHeight: 0,
              showDatePickerButton: false,
              monthViewSettings: const MonthViewSettings(
                showTrailingAndLeadingDates: false,
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
              monthCellBuilder: (context, details) {
                final isToday =
                    details.date.year == DateTime.now().year &&
                    details.date.month == DateTime.now().month &&
                    details.date.day == DateTime.now().day;
                return Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 4),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isToday)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
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
            ),
          ),
        ],
      ),
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
              padding: const EdgeInsets.all(16),
              height: 220,
              child: Column(
                children: [
                  const Text("년도 / 월 선택", style: TextStyle(fontSize: 16)),
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
                      const SizedBox(width: 16),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _controller.displayDate = DateTime(tempYear, tempMonth);
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("이동하기"),
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
                        icon: const Icon(Icons.add),
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
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditDialog(appt);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => _appointments.remove(appt));
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("일정 추가", style: TextStyle(fontSize: 18)),
              TextField(
                decoration: const InputDecoration(labelText: '제목'),
                onChanged: (value) => title = value,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text("추가"),
                onPressed: () {
                  final newAppointment = Appointment(
                    startTime: DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      start.hour,
                      start.minute,
                    ),
                    endTime: DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      end.hour,
                      end.minute,
                    ),
                    subject: title,
                    color: Colors.orange,
                  );
                  setState(() => _appointments.add(newAppointment));
                  Navigator.pop(context);
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("일정 수정", style: TextStyle(fontSize: 18)),
              TextField(
                controller: TextEditingController(text: title),
                decoration: const InputDecoration(labelText: '제목'),
                onChanged: (value) => title = value,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text("수정"),
                onPressed: () {
                  final index = _appointments.indexOf(oldAppointment);
                  if (index == -1) return;

                  final updated = Appointment(
                    startTime: oldAppointment.startTime,
                    endTime: oldAppointment.endTime,
                    subject: title,
                    color: oldAppointment.color,
                  );

                  setState(() => _appointments[index] = updated);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
