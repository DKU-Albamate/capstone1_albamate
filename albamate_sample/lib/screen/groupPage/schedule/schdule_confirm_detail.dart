import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleConfirmViewPage extends StatelessWidget {
  final String title;
  final String createdAt;
  final String scheduleMapJson;

  const ScheduleConfirmViewPage({
    super.key,
    required this.title,
    required this.createdAt,
    required this.scheduleMapJson,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> scheduleMap = json.decode(scheduleMapJson);
    final parsedMap = scheduleMap.map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );

    final appointments = <Appointment>[];
    parsedMap.forEach((dateStr, users) {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        for (var user in users) {
          appointments.add(
            Appointment(
              startTime: date,
              endTime: date.add(const Duration(hours: 1)),
              subject: user,
              color: Colors.blue,
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              '생성일: ${createdAt.split("T")[0]}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: SfCalendar(
              view: CalendarView.month,
              dataSource: MeetingDataSource(appointments),
              todayHighlightColor: Colors.red,
              cellBorderColor: Colors.transparent,
              showDatePickerButton: false,
              headerHeight: 0,
              monthViewSettings: const MonthViewSettings(
                showTrailingAndLeadingDates: false,
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
