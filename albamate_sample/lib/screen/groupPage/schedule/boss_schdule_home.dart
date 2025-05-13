import 'package:flutter/material.dart';
import 'package:albamate_sample/component/schedule_tab_bar.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_confirm_nav.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_request_nav.dart';

class BossScheduleHomePage extends StatefulWidget {
  final String groupId; // ✅ 그룹 ID를 필수로 받음

  const BossScheduleHomePage({super.key, required this.groupId});

  @override
  State<BossScheduleHomePage> createState() => _BossScheduleHomePageState();
}

class _BossScheduleHomePageState extends State<BossScheduleHomePage> {
  int selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ScheduleRequestNav(
        groupId: widget.groupId,
        // TODO: ⚠️ 현재 userRole 임시 사용 중 (백엔드 ownerId 연동 시 제거 예정)
        userRole: '사장님',
      ), // ✅ 그룹 ID 전달
      ScheduleConfirmNav(groupId: widget.groupId),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('스케줄 게시판 (사장님 뷰)')),
      body: Column(
        children: [
          ScheduleTabBar(
            selectedIndex: selectedIndex,
            onTabSelected: _onTabSelected,
          ),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}
