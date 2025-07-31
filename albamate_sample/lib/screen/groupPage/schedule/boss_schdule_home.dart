import 'package:flutter/material.dart';
import 'package:albamate_sample/component/schedule_tab_bar.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_confirm_nav.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_request_nav.dart';

class BossScheduleHomePage extends StatefulWidget {
  /// 그룹 ID는 필수, initialIndex는 선택(기본값 0)
  final String groupId;
  final int initialIndex;

  const BossScheduleHomePage({
    super.key,
    required this.groupId,
    this.initialIndex = 0,
  });

  @override
  State<BossScheduleHomePage> createState() => _BossScheduleHomePageState();
}

class _BossScheduleHomePageState extends State<BossScheduleHomePage> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    // 부모에서 전달받은 initialIndex를 사용해 탭 초기값 설정
    selectedIndex = widget.initialIndex;
  }

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
         onScheduleConfirmed: () {
           setState(() {
             selectedIndex = 1; // “스케줄 확정” 탭으로 전환
           });
         },
      ),
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
