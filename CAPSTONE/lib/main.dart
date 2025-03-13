import 'package:flutter/material.dart';
import 'ui/onboarding.dart'; // ✅ 온보딩 화면 추가
import 'ui/login.dart';
import 'ui/signup.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(), // ✅ 온보딩 화면을 시작 화면으로 설정
      routes: {
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
