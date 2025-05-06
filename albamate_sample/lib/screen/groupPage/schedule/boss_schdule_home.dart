import 'package:flutter/material.dart';
import 'package:albamate_sample/component/schedule_tab_bar.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_confirm_nav.dart';
import 'package:albamate_sample/screen/groupPage/schedule/schedule_request_nav.dart';

class BossScheduleHomePage extends StatefulWidget {
  const BossScheduleHomePage({super.key});

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
      const ScheduleRequestNav(groupId: 'dummy-group-id'),
      const ScheduleConfirmNav(groupId: 'dummy-group-id'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('스케줄 게시판')),
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
