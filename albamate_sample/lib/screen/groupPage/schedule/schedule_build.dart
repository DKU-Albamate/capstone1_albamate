import 'dart:convert';
import 'package:albamate_sample/screen/groupPage/schedule/boss_schdule_home.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_confirm_nav.dart';


class ScheduleBuildPage extends StatefulWidget {
  final Map<String, List<String>> unavailableMap;
  final Map<String, String> userNameMap;
  final String scheduleId;
  final String groupId;

  const ScheduleBuildPage({
    super.key,
    required this.unavailableMap,
    required this.userNameMap,
    required this.scheduleId,
    required this.groupId,
  });

  @override
  State<ScheduleBuildPage> createState() => _ScheduleBuildPageState();
}

class _ScheduleBuildPageState extends State<ScheduleBuildPage> {
  DateTime selectedDate = DateTime.now();
  int weeklyLimit = 3;
  final TextEditingController _titleController = TextEditingController();

  late final List<String> selectedUsers;
  late final Map<String, Set<DateTime>> parsedUnavailableMap;
  late final Map<String, Set<DateTime>> assignedDates;

  @override
  void initState() {
    super.initState();

    // 불가능 날짜 제출한 알바생만 대상으로
    selectedUsers = widget.unavailableMap.keys
        .where((uid) => widget.userNameMap.containsKey(uid))
        .map((uid) => widget.userNameMap[uid]!)
        .toList();

    parsedUnavailableMap = {
      for (var entry in widget.unavailableMap.entries)
        widget.userNameMap[entry.key]!: entry.value.map((e) => DateTime.parse(e)).toSet()
    };

    assignedDates = {
      for (var name in selectedUsers) name: <DateTime>{}
    };
  }

  DateTime getKoreanWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  DateTime getKoreanWeekEnd(DateTime date) {
    return date.add(Duration(days: 6 - (date.weekday % 7)));
  }

  bool isOverLimit(String user, DateTime date) {
    final weekStart = getKoreanWeekStart(date);
    final weekEnd = getKoreanWeekEnd(date);
    final count = assignedDates[user]!
        .where((d) => !d.isBefore(weekStart) && !d.isAfter(weekEnd))
        .length;
    return count >= weeklyLimit;
  }

  void toggleAssignment(String user, DateTime date) {
    setState(() {
      if (assignedDates[user]!.contains(date)) {
        assignedDates[user]!.remove(date);
      } else {
        assignedDates[user]!.add(date);
      }
    });
  }

  Future<void> confirmSchedule() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('제목을 입력해주세요.')));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('선택된 인원이 없습니다.')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    final response = await http.patch(
      Uri.parse(
          'https://backend-schedule-vs8b.onrender.com/api/schedules/${widget.scheduleId}/confirm'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'confirmedTitle': title,
        'scheduleMap': scheduleMap,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('스케줄 확정 완료')),
      );

      Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => Scaffold(
      appBar: AppBar(title: const Text('스케줄 확정')),
      body: ScheduleConfirmNav(groupId: widget.groupId),
    ),
  ),
);
    } else {
      print('❌ 실패: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('스케줄 확정 실패')),
      );
    }
  }

  List<String> getAvailableUsersForDate(DateTime date) {
    return selectedUsers
        .where((u) => !(parsedUnavailableMap[u]?.contains(date) ?? false))
        .toList();
  }

  Widget buildCalendar() {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final firstWeekday = firstDay.weekday % 7;
    final totalDays = lastDay.day;

    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 16.0 * 2;
    final spacing = 2.0 * 6;
    final boxWidth = (screenWidth - padding - spacing) / 7;

    List<Row> rows = [];
    List<Widget> currentRow = [];

    for (int i = 0; i < firstWeekday; i++) {
      currentRow.add(SizedBox(width: boxWidth, height: boxWidth * 1.5));
    }

    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(selectedDate.year, selectedDate.month, day);
      final isSelected = selectedDate.day == day;
      final assignedUsers = selectedUsers
          .where((u) => assignedDates[u]?.contains(date) ?? false)
          .toList();

      currentRow.add(
        GestureDetector(
          onTap: () => setState(() => selectedDate = date),
          child: Container(
            width: boxWidth,
            constraints: BoxConstraints(minHeight: boxWidth * 1.5),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
              borderRadius: BorderRadius.circular(6),
              color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white,
            ),
            child: Column(
              children: [
                Text(
                  '$day',
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Column(
                  children: assignedUsers
                      .map((user) => Text(
                            user,
                            style: const TextStyle(fontSize: 8),
                            overflow: TextOverflow.ellipsis,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      );

      if (currentRow.length == 7) {
        rows.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: currentRow));
        currentRow = [];
      }
    }

    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(SizedBox(width: boxWidth, height: boxWidth * 1.5));
      }
      rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: currentRow));
    }

    return Column(children: rows);
  }

  @override
  Widget build(BuildContext context) {
    final availableUsers = getAvailableUsersForDate(selectedDate);

    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 16.0 * 2;
    final spacing = 2.0 * 6;
    final boxWidth = (screenWidth - padding - spacing) / 7;

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
                  onPressed: () => setState(() {
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
                  onPressed: () => setState(() {
                    selectedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month + 1,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final dayNames = ['일', '월', '화', '수', '목', '금', '토'];
                return SizedBox(
                  width: boxWidth,
                  child: Text(
                    dayNames[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }),
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
                trailing: isLimited && !isSelected
                    ? const Icon(Icons.warning, color: Colors.red)
                    : Icon(
                        isSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: isSelected ? Colors.blue : null,
                      ),
                onTap: isLimited && !isSelected
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('$user님은 이미 주 $weeklyLimit일 초과입니다.'),
                          ),
                        )
                    : () => toggleAssignment(user, selectedDate),
              );
            }),
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
