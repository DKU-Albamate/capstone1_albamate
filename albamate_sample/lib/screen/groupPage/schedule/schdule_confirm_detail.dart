import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleConfirmDetailPage extends StatefulWidget {
  final String title;
  final String createdAt;
  final String scheduleMapJson;

  const ScheduleConfirmDetailPage({
    super.key,
    required this.title,
    required this.createdAt,
    required this.scheduleMapJson,
  });

  @override
  State<ScheduleConfirmDetailPage> createState() =>
      _ScheduleConfirmDetailPageState();
}

class _ScheduleConfirmDetailPageState extends State<ScheduleConfirmDetailPage> {
  late Map<DateTime, List<String>> _events;
  bool isChecked = false; // 체크박스 상태 관리
  DateTime _focusedDay = DateTime.now();
  String? userName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _parseSchedule();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        setState(() {
          userName = doc['name'] ?? '';
        });
      }
    }
  }

  void _parseSchedule() {
    final Map<String, dynamic> scheduleMap = json.decode(
      widget.scheduleMapJson,
    );
    final parsedMap = scheduleMap.map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );

    _events = {};
    parsedMap.forEach((dateStr, users) {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        _events[DateTime(date.year, date.month, date.day)] = users;
      }
    });
  }

  void _updateCheckmark(bool selected) {
    // 체크박스 상태 업데이트 시 처리할 로직
    print('체크 상태: $selected');
    // 이후 서버 업데이트 등의 로직 추가 가능
  }

  // 본인의 일정만 필터링
  Map<DateTime, String> _getMySchedules() {
    Map<DateTime, String> mySchedules = {};
    
    if (userName == null || userName!.isEmpty) {
      return mySchedules;
    }

    _events.forEach((date, users) {
      if (users.contains(userName)) {
        mySchedules[date] = userName!;
      }
    });

    return mySchedules;
  }

  // 개인 캘린더에 일정 연동
  Future<void> _syncToPersonalCalendar() async {
    if (userName == null || userName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 불러올 수 없습니다.')),
      );
      return;
    }

    final mySchedules = _getMySchedules();
    if (mySchedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('본인의 일정이 없습니다.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 각 일정을 개인 캘린더에 추가
      int successCount = 0;
      for (final entry in mySchedules.entries) {
        final date = entry.key;
        final name = entry.value;
        
        // 기본 근무 시간 (09:00-18:00)으로 설정
        final startTime = DateTime(date.year, date.month, date.day, 9, 0);
        final endTime = DateTime(date.year, date.month, date.day, 18, 0);

        final response = await http.post(
          Uri.parse('https://backend-vgbf.onrender.com/appointments'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_uid': user.uid,
            'title': '${widget.title} - $name',
            'start_time': startTime.toIso8601String(),
            'end_time': endTime.toIso8601String(),
            'color': '#006FFD',
            'source': 'group_sync'
          }),
        );

        if (response.statusCode == 201) {
          successCount++;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount개의 일정이 개인 캘린더에 연동되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('연동 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int year = _focusedDay.year;
    final int month = _focusedDay.month;

    final daysInMonth = List.generate(
      DateTime(year, month + 1, 0).day,
      (index) => DateTime(year, month, index + 1),
    );

    final mySchedules = _getMySchedules();
    final hasMySchedules = mySchedules.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                '생성일: ${widget.createdAt.split("T")[0]}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            
            // 본인 일정 정보 표시
            if (userName != null && hasMySchedules)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF006FFD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF006FFD).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFF006FFD)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$userName 님의 일정',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006FFD),
                            ),
                          ),
                          Text(
                            '${mySchedules.length}일 근무 예정',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // 커스텀 달력 Table UI - BossHomecalendar 스타일에 맞춤
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
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            children: [
              MSHCheckbox(
                size: 22,
                value: isChecked,
                colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                  checkedColor: Colors.blue,
                ),
                style: MSHCheckboxStyle.fillScaleColor,
                onChanged: (selected) {
                  setState(() {
                    isChecked = selected;
                  });
                  _updateCheckmark(selected);
                },
              ),
              const SizedBox(width: 8),
              Text('확인', style: TextStyle(color: Colors.grey[800])),
              
              const Spacer(),
              
              // 개인 캘린더 연동 버튼
              if (hasMySchedules)
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _syncToPersonalCalendar,
                  icon: isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync, size: 16),
                  label: Text(isLoading ? '연동 중...' : '개인 캘린더 연동'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006FFD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 달력 테이블에 표시될 각 날짜 쉘 생성 - BossHomecalendar 스타일 적용
  List<TableRow> _buildCalendarRows(List<DateTime> daysInMonth) {
    List<TableRow> rows = [];
    List<Widget> cells = [];
    int startWeekday = daysInMonth.first.weekday % 7; //일욜 시작

    for (int i = 0; i < startWeekday; i++) {
      cells.add(Container(height: 80));
    }

    for (final date in daysInMonth) {
      final today = DateTime.now();
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final events = _events[date] ?? [];
      final isMySchedule = userName != null && events.contains(userName);

      cells.add(
        Container(
          padding: EdgeInsets.all(4),
          constraints: BoxConstraints(minHeight: 80 + 20.0 * events.length),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 숫자, 오늘 강조
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
              // 일정 리스트 미리보기
              ...events
                  .take(10)
                  .map(
                    (e) => Container(
                      height: 20,
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 2),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: e == userName 
                          ? const Color(0xFF006FFD).withOpacity(0.3)  // 본인 일정은 파란색
                          : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        e,
                        style: TextStyle(
                          fontSize: 10, 
                          color: e == userName ? Colors.white : Colors.black,
                          fontWeight: e == userName ? FontWeight.bold : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              // 10개 이상 쌓이면 +n개 로 표시
              if (events.length > 10)
                Text(
                  '+${events.length - 10}',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ),
      );

      // 한 줄 완성 시 테이블에 추가
      if (cells.length == 7) {
        rows.add(TableRow(children: List.from(cells)));
        cells.clear();
      }
    }

    // 마지막 주 빈 셀 보완
    if (cells.isNotEmpty) {
      while (cells.length < 7) {
        cells.add(Container(height: 80));
      }
      rows.add(TableRow(children: List.from(cells)));
    }

    return rows;
  }
}
