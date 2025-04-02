import 'package:flutter/material.dart';
import '../screen/homePage/boss/boss_homecalendar.dart';
import '../screen/homePage/boss/boss_mypage.dart';
import '../screen/homePage/boss/boss_homegroup.dart';

class HomeNavigation extends StatelessWidget {
  final int currentIndex; // 현재 선택된 페이지 인덱스

  const HomeNavigation({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // 현재 페이지와 같은 경우 다시 로드하지 않음

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = BossHomegroup(); // 그룹 관리 페이지
        break;
      case 1:
        nextScreen = BossHomecalendar(); // 캘린더 페이지
        break;
      case 2:
        nextScreen = BossMypage(); // 마이페이지
        break;
      default:
        nextScreen = BossHomecalendar(); // 기본값
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.group), label: '그룹 관리'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '캘린더'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
      ],
    );
  }
}
