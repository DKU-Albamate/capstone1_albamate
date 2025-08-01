import 'package:flutter/material.dart';
import '../screen/homePage/worker/worker_group.dart';
import '../screen/homePage/worker/worker_homecalendar.dart';
import '../screen/homePage/worker/worker_mypage.dart';

class HomeNavigationWorker extends StatelessWidget {
  final int currentIndex;

  const HomeNavigationWorker({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = WorkerGroup(); // 그룹 관리
        break;
      case 1:
        nextScreen = WorkerHomecalendar(); // 캘린더
        break;
      case 2:
        nextScreen = WorkerMyPage(); // 마이페이지
        break;
      default:
        nextScreen = WorkerHomecalendar();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Color(0xff006FFD),
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
