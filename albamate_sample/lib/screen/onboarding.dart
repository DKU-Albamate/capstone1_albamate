// onboarding.dart
// 앱을 처음 실행했을 때, 사용자에게 보여지는 화면
import 'package:albamate_sample/screen/signup_step1.dart'; // SignupStep1 import 추가
import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/login_step1.dart'; // 로그인 화면 import 추가

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          const Text(
            '알바메이트',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            '쉽고 간편한 알바 관리',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupStep1(email: ''),
                    ),
                  );
                },
                child: const Text(
                  '시작하기',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '이미 계정이 있으신가요? ',
                style: TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ), // 로그인 화면으로 이동
                  );
                },
                child: const Text('로그인', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
