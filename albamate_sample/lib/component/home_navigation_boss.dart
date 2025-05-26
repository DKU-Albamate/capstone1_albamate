import 'package:flutter/material.dart';
import '../screen/homePage/boss/boss_homecalendar.dart';
import '../screen/homePage/boss/boss_mypage.dart';
import '../screen/homePage/boss/boss_group.dart';

class HomeNavigationBoss extends StatelessWidget {
  final int currentIndex;

  const HomeNavigationBoss({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = BossGroup();
        break;
      case 1:
        nextScreen = BossHomecalendar();
        break;
      case 2:
        nextScreen = BossMypage();
        break;
      default:
        nextScreen = BossHomecalendar();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100], // ✅ 아주 연한 회색 배경
        border: const Border(
          top: BorderSide(color: Colors.grey, width: 0.5), // ✅ 위쪽 얇은 구분선
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent, // ✅ Container 색상을 그대로 사용
        elevation: 0, // ✅ 그림자 제거
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        selectedItemColor: const Color(0xFF006FFD),
        unselectedItemColor: Colors.grey,
        iconSize: 20,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '그룹 관리'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}
