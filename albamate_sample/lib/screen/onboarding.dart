// onboarding.dart
// 앱을 처음 실행했을 때, 사용자에게 보여지는 화면
import 'package:albamate_sample/screen/signup/signup_step1.dart'; // SignupStep1 import 추가
import 'package:flutter/material.dart';
import 'package:albamate_sample/screen/login/login_step1.dart'; // 로그인 화면 import 추가

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        // 위에서 아래로 요소들 배치
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          const Text(
            // 앱 이름
            '알바메이트',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xff1F2024),
            ),
            textAlign: TextAlign.center,
          ),
          // 앱 이름과 설명 사이 간격
          const SizedBox(height: 4),
          const Text(
            // 앱 설명
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF006FFD),
                  minimumSize: Size(double.infinity, 46),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // 클릭 시 signup_step1.dart로 이동
                      builder: (context) => const SignupStep1(email: ''),
                    ),
                  );
                },
                child: const Text(
                  '시작하기',
                  style: TextStyle(
                    color: Colors.white, // 글자색
                    fontSize: 16, // 글씨 크기 (예: 18)
                    fontWeight: FontWeight.w800, // 글씨 굵기
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                // 로그인
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
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    color: Color(0xFF006FFD), // 글자색
                    fontWeight: FontWeight.w600, // 글씨 굵기
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
