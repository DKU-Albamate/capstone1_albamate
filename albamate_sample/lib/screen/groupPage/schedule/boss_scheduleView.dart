import 'package:albamate_sample/screen/groupPage/schedule/schedule_build.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BossScheduleViewPage extends StatefulWidget {
  final String scheduleId;

  const BossScheduleViewPage({super.key, required this.scheduleId});

  @override
  State<BossScheduleViewPage> createState() => _BossScheduleViewPageState();
}

class _BossScheduleViewPageState extends State<BossScheduleViewPage> {
  final List<String> mockUsers = ['Alice', 'Bob', 'Charlie'];
  final Map<String, Set<int>> mockUnavailable = {
    'Alice': {3, 7, 15},
    'Bob': {5, 7, 23},
    'Charlie': {10, 15, 20},
  };

  DateTime focusedMonth = DateTime.now();

  List<Widget> buildCalendarDays(String user) {
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    for (int i = 0; i < firstWeekday; i++) {
      currentRow.add(const SizedBox(width: 40, height: 40));
    }

    for (int day = 1; day <= totalDays; day++) {
      final isUnavailable = mockUnavailable[user]?.contains(day) ?? false;

      currentRow.add(
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: isUnavailable ? Colors.red : Colors.grey),
            borderRadius: BorderRadius.circular(6),
            color: isUnavailable ? Colors.red[100] : Colors.transparent,
          ),
          child: Text('$day'),
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
    final monthText = DateFormat('yyyy. MM').format(focusedMonth);

    return DefaultTabController(
      length: mockUsers.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('알바생 스케줄 보기'),
          bottom: TabBar(
            isScrollable: true,
            tabs: mockUsers.map((user) => Tab(text: user)).toList(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children:
                    mockUsers.map((user) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: () {
                                    setState(() {
                                      focusedMonth = DateTime(
                                        focusedMonth.year,
                                        focusedMonth.month - 1,
                                      );
                                    });
                                  },
                                ),
                                Text(
                                  monthText,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () {
                                    setState(() {
                                      focusedMonth = DateTime(
                                        focusedMonth.year,
                                        focusedMonth.month + 1,
                                      );
                                    });
                                  },
                                ),
                              ],
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
                            ...buildCalendarDays(user),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScheduleBuildPage(),
                      ),
                    );
                  },
                  child: const Text('스케줄 작성하러 가기'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
