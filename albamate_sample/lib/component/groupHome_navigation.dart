import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/groupPage/schedule/boss_schdule_home.dart';
import 'package:albamate_sample/screen/groupPage/schedule/worker_schedule_home.dart'; // ✅ 알바 전용 홈 추가
import 'package:albamate_sample/screen/groupPage/groupCalendar.dart';
import 'package:albamate_sample/screen/groupPage/groupMypage.dart';
import 'package:albamate_sample/screen/groupPage/groupHome.dart';
import 'groupNotice_navigation.dart';

// 그룹 네비게이션
class GroupNav extends StatefulWidget {
  final String groupId;
  final String userRole; // ✅ 현재 로그인 시 받은 '사장님' or '알바생'

  const GroupNav({super.key, required this.groupId, required this.userRole});

  @override
  _GroupNavState createState() => _GroupNavState();
}

class _GroupNavState extends State<GroupNav> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      // TODO: ⚠️ 현재 userRole 임시 사용 중 (백엔드 ownerId 연동 시 제거 예정)
      // 현재는 로그인 시 받은 role을 기준으로 분기
      // 향후 그룹 ownerId를 백엔드에서 가져와서 비교 후 이 부분만 교체
      widget.userRole.trim() == '사장님'
      // widget.userRole.trim() == '알바생'
          ? BossScheduleHomePage(groupId: widget.groupId)
          : WorkerScheduleHomePage(groupId: widget.groupId),
      NoticePageNav(groupId: widget.groupId),
      GroupHomePage(groupId: widget.groupId),
      GroupCalendarPage(userRole: widget.userRole, groupId: widget.groupId),
      GroupMyPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// 하단 네비게이션 바 (공통)
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: const BoxDecoration(color: Colors.white),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xff006FFD),
        unselectedItemColor: Color(0xff71727A),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 10),
        unselectedLabelStyle: TextStyle(fontSize: 10),
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_send, size: 20),
            label: '스케줄',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign, size: 20),
            label: '공지사항',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 20),
            label: '홈화면',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month, size: 20),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 20),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}