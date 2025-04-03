import 'package:flutter/material.dart';
import '/component/home_navigation.dart';

class BossMypage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('마이페이지')),
      body: Center(child: Text('마이페이지 화면', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: HomeNavigation(currentIndex: 2), // 네비게이션 추가
    );
  }
}
