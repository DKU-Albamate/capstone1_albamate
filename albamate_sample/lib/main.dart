import 'package:albamate_sample/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screen/onboarding.dart';
import 'screen/signup/signup_step1.dart';
import 'screen/login/login_step1.dart'; // 로그인 초기 화면

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 초기 화면 설정
      home: const OnboardingScreen(),
      // 라우트 설정
      routes: {
        '/signup_step1': (context) => const SignupStep1(email: ''),
        '/login': (context) => const LoginScreen(),
      },
      onUnknownRoute: (settings) {
        // 정의되지 않은 경로 요청 시 기본 화면으로 이동
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
