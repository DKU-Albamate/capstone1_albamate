import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screen/onboarding.dart';
import 'screen/signup/signup_step1.dart';
import 'screen/login/login_step1.dart';

// 새로 추가할 홈 화면
// import 'screen/homePage/boss/boss_homeCalendar.dart';
// import 'screen/homePage/worker/worker_homeCalendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ✅ 여기에서 시작 화면을 전환할 수 있음
      home: const OnboardingScreen(),
      // home: const BossHomecalendar(), // 또는 WorkerHomeCalendar()
      routes: {
        '/signup_step1': (context) => const SignupStep1(email: ''),
        '/login': (context) => const LoginScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
          // builder: (context) => const BossHomecalendar(), // fallback 화면
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
