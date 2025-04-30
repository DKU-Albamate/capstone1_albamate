import 'package:flutter/material.dart';
import '/component/home_navigation.dart';

class BossHomegroup extends StatelessWidget {
  const BossHomegroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('그룹 관리')),
      body: Center(child: Text('그룹 관리 페이지', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: HomeNavigation(currentIndex: 0), // 네비게이션 추가
    );
  }
}
