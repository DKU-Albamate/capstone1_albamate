import 'package:albamate_sample/screen/groupPage/schedule/schedule_build.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class BossScheduleViewPage extends StatefulWidget {
  final String groupId;
  final String scheduleId;
  final int year;
  final int month;

  const BossScheduleViewPage({
    required this.groupId,
    super.key,
    required this.scheduleId,
    required this.year,
    required this.month,
  });

  @override
  State<BossScheduleViewPage> createState() => _BossScheduleViewPageState();
}

class _BossScheduleViewPageState extends State<BossScheduleViewPage> {
  late DateTime fixedMonth;
  bool isLoading = true;

  Map<String, List<String>> unavailableMap = {};
  Map<String, String> userNameMap = {};

  @override
  void initState() {
    super.initState();
    fixedMonth = DateTime(widget.year, widget.month);
    fetchUnavailableData();
  }

  Future<void> fetchUnavailableData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      final response = await http.get(
        Uri.parse('https://backend-schedule-vs8b.onrender.com/api/schedules/${widget.scheduleId}/unavailable/all'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      final decoded = jsonDecode(response.body);
      final dynamic rawData = decoded['data'];

      if (rawData is Map<String, dynamic>) {
        Map<String, List<String>> parsedData = {};
        rawData.forEach((uid, list) {
          parsedData[uid] = List<String>.from((list as List).map((e) => e.toString()));
        });

        final uids = parsedData.keys.toList();

        if (uids.isEmpty) {
          setState(() {
            unavailableMap = {};
            userNameMap = {};
            isLoading = false;
          });
          return;
        }

        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: uids)
            .get();

        Map<String, String> nameMap = {};
        for (var doc in snapshot.docs) {
          nameMap[doc.id] = doc.data()['name'] ?? '알 수 없음';
        }

        setState(() {
          unavailableMap = parsedData;
          userNameMap = nameMap;
          isLoading = false;
        });
      } else {
        throw Exception('예상치 못한 데이터 형식');
      }
    } catch (e) {
      print('❌ 에러 발생: $e');
      setState(() {
        unavailableMap = {};
        userNameMap = {};
        isLoading = false;
      });
    }
  }

  List<Widget> buildCalendarDays(List<String> unavailableDates) {
    final firstDayOfMonth = DateTime(fixedMonth.year, fixedMonth.month, 1);
    final lastDayOfMonth = DateTime(fixedMonth.year, fixedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    for (int i = 0; i < firstWeekday; i++) {
      currentRow.add(Container(width: 40, height: 40, margin: const EdgeInsets.all(2)));
    }

    for (int day = 1; day <= totalDays; day++) {
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime(fixedMonth.year, fixedMonth.month, day));
      final isUnavailable = unavailableDates.contains(dateStr);

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
        rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: currentRow));
        currentRow = [];
      }
    }

    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(Container(width: 40, height: 40, margin: const EdgeInsets.all(2)));
      }
      rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: currentRow));
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final monthText = DateFormat('yyyy. MM').format(fixedMonth);
    final userUids = unavailableMap.keys.toList();

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: userUids.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('알바생 스케줄 보기'),
          bottom: userUids.isEmpty
              ? null
              : TabBar(
                  isScrollable: true,
                  tabs: userUids.map((uid) {
                    final name = userNameMap[uid] ?? uid;
                    return Tab(text: name);
                  }).toList(),
                ),
        ),
        body: userUids.isEmpty
            ? const Center(child: Text('아직 제출한 알바생이 없습니다.'))
            : Column(
                children: [
                  const SizedBox(height: 16),
                  Text(monthText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(width: 40, child: Center(child: Text('일'))),
                      SizedBox(width: 40, child: Center(child: Text('월'))),
                      SizedBox(width: 40, child: Center(child: Text('화'))),
                      SizedBox(width: 40, child: Center(child: Text('수'))),
                      SizedBox(width: 40, child: Center(child: Text('목'))),
                      SizedBox(width: 40, child: Center(child: Text('금'))),
                      SizedBox(width: 40, child: Center(child: Text('토'))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: userUids.map((uid) {
                        final dates = unavailableMap[uid] ?? [];
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(children: buildCalendarDays(dates)),
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
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScheduleBuildPage(
                                unavailableMap: unavailableMap,
                                userNameMap: userNameMap,
                                scheduleId: widget.scheduleId,
                                groupId: widget.groupId,
                                onConfirmed: () {
                                  // 스케줄 작성 페이지에서 확정이 완료되면

                                  Navigator.pop(context, true); // BossScheduleViewPage를 닫으면서 true 반환
                                },
                              ),
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
