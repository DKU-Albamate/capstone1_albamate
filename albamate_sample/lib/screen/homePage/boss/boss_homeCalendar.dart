import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '/component/home_navigation.dart';

class BossHomecalendar extends StatefulWidget {
  @override
  _BossHomecalendarState createState() => _BossHomecalendarState();
}

class _BossHomecalendarState extends State<BossHomecalendar> {
  CalendarView _calendarView = CalendarView.month; // 기본: 월간 보기

  @override
  Widget build(BuildContext context) {
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
      body: SfCalendar(
        view: _calendarView,
        firstDayOfWeek: 1,
        dataSource: MeetingDataSource(getAppointments()),
        todayHighlightColor: Colors.red,
        timeSlotViewSettings: TimeSlotViewSettings(
          timeIntervalHeight: 60,
          timeFormat: 'HH:mm',
          timeInterval: Duration(hours: 1),
        ),
      ),
      bottomNavigationBar: HomeNavigation(currentIndex: 1), // 캘린더는 index 1
    );
  }

  /// 기본 일정 목록
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

/// 일정 데이터 소스
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
