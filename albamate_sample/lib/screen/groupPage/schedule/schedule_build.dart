import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_confirm_nav.dart';

class ScheduleBuildPage extends StatefulWidget {
  const ScheduleBuildPage({super.key});

  @override
  State<ScheduleBuildPage> createState() => _ScheduleBuildPageState();
}

class _ScheduleBuildPageState extends State<ScheduleBuildPage> {
  DateTime selectedDate = DateTime.now();
  int weeklyLimit = 3;
  final TextEditingController _titleController = TextEditingController();

  final List<String> allUsers = ['Alice', 'Bob', 'Charlie', 'David'];
  final Map<String, Set<DateTime>> unavailableMap = {
    'Alice': {DateTime(2025, 5, 3)},
    'Bob': {DateTime(2025, 5, 4), DateTime(2025, 5, 5)},
    'Charlie': {DateTime(2025, 5, 6)},
    'David': {},
  };
  final Map<String, Set<DateTime>> assignedDates = {
    'Alice': {},
    'Bob': {},
    'Charlie': {},
    'David': {},
  };

  bool isOverLimit(String user, DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final count =
        assignedDates[user]!
            .where((d) => !d.isBefore(weekStart) && !d.isAfter(weekEnd))
            .length;
    return count >= weeklyLimit;
  }

  void toggleAssignment(String user, DateTime date) {
    if (!mounted) return;
    setState(() {
      if (assignedDates[user]!.contains(date)) {
        assignedDates[user]!.remove(date);
      } else {
        assignedDates[user]!.add(date);
      }
    });
  }

  void confirmSchedule() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요.')));
      return;
    }

    final Map<String, List<String>> scheduleMap = {};
    for (final user in assignedDates.keys) {
      for (final date in assignedDates[user]!) {
        final key = DateFormat('yyyy-MM-dd').format(date);
        scheduleMap.putIfAbsent(key, () => []).add(user);
      }
    }

    if (scheduleMap.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('선택된 인원이 없습니다.')));
      return;
    }

    ScheduleConfirmNav.addConfirmedSchedule({
      'title': title,
      'createdAt': DateTime.now().toIso8601String(),
      'scheduleMap': scheduleMap,
    });

    Navigator.pop(context);
  }

  Widget buildCalendar() {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final firstWeekday = firstDay.weekday % 7; // Sunday = 0
    final totalDays = lastDay.day;

    List<Row> rows = [];
    List<Widget> currentRow = [];

    for (int i = 0; i < firstWeekday; i++) {
      currentRow.add(const SizedBox(width: 44, height: 60));
    }

    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(selectedDate.year, selectedDate.month, day);
      final isSelected = selectedDate.day == day;
      final assignedUsers =
          allUsers
              .where((u) => assignedDates[u]?.contains(date) ?? false)
              .toList();

      currentRow.add(
        GestureDetector(
          onTap: () => setState(() => selectedDate = date),
          child: Container(
            width: 44,
            height: 60,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
              borderRadius: BorderRadius.circular(6),
              color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child:
                      assignedUsers.length <= 3
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                                assignedUsers
                                    .map(
                                      (user) => Text(
                                        user,
                                        style: const TextStyle(fontSize: 8),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                    .toList(),
                          )
                          : const Text('...더보기', style: TextStyle(fontSize: 8)),
                ),
              ],
            ),
          ),
        ),
      );

      if (currentRow.length == 7) {
        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: currentRow,
          ),
        );
        currentRow = [];
      }
    }

    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(const SizedBox(width: 44, height: 60));
      }
      rows.add(
        Row(mainAxisAlignment: MainAxisAlignment.center, children: currentRow),
      );
    }

    return Column(children: rows);
  }

  List<String> getAvailableUsersForDate(DateTime date) {
    return allUsers
        .where((u) => !(unavailableMap[u]?.contains(date) ?? false))
        .toList();
  }

  List<String> getUnavailableUsersForDate(DateTime date) {
    return allUsers
        .where((u) => unavailableMap[u]?.contains(date) ?? false)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final availableUsers = getAvailableUsersForDate(selectedDate);
    final unavailableUsers = getUnavailableUsersForDate(selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('스케줄 확정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "스케줄 제목 입력"),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed:
                      () => setState(() {
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month - 1,
                        );
                      }),
                ),
                Text(
                  DateFormat('yyyy. MM').format(selectedDate),
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed:
                      () => setState(() {
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month + 1,
                        );
                      }),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            buildCalendar(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('주 최대 근무일수: '),
                DropdownButton<int>(
                  value: weeklyLimit,
                  onChanged: (val) => setState(() => weeklyLimit = val!),
                  items: List.generate(
                    7,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text('${i + 1}일'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('가능한 인원', style: TextStyle(fontWeight: FontWeight.bold)),
            ...availableUsers.map((user) {
              final isSelected = assignedDates[user]!.contains(selectedDate);
              final isLimited = isOverLimit(user, selectedDate);
              return ListTile(
                title: Text(user),
                trailing:
                    isLimited && !isSelected
                        ? const Icon(Icons.warning, color: Colors.red)
                        : Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected ? Colors.blue : null,
                        ),
                onTap:
                    isLimited && !isSelected
                        ? () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$user님은 이미 주 $weeklyLimit일 초과입니다.'),
                          ),
                        )
                        : () => toggleAssignment(user, selectedDate),
              );
            }),
            const Text(
              '불가능한 인원',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            ...unavailableUsers.map(
              (user) => ListTile(
                title: Text(user, style: const TextStyle(color: Colors.grey)),
                trailing: const Icon(Icons.block, color: Colors.grey),
                enabled: false,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: confirmSchedule,
                child: const Text('스케줄 확정'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
