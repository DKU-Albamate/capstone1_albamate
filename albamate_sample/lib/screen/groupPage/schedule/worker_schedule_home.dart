import 'package:flutter/material.dart';
import 'package:albamate_sample/component/schedule_tab_bar.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_confirm_nav.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_request_nav.dart';

class WorkerScheduleHomePage extends StatefulWidget {
  final String groupId; // ✅ 그룹 ID를 필수로 받음

  const WorkerScheduleHomePage({super.key, required this.groupId});

  @override
  State<WorkerScheduleHomePage> createState() => _WorkerScheduleHomePageState();
}

class _WorkerScheduleHomePageState extends State<WorkerScheduleHomePage> {
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
        userRole: '알바생',
      ), // ✅ 요청 탭 (작성 불가, 보기만)
      ScheduleConfirmNav(groupId: widget.groupId), // ✅ 확정 스케줄 확인 탭
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('스케줄 게시판 (알바생 뷰)')),
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
