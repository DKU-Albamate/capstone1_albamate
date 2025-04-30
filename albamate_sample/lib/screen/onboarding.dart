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
        mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
        crossAxisAlignment: CrossAxisAlignment.center, // 수평 중앙 정렬
        children: [
          const Spacer(), // 상단 여백을 위한 공간
          
          // 앱 이름 표시
          const Text(
            '알바메이트',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4), // 텍스트 간 간격
          
          // 앱 설명 텍스트
          const Text(
            '쉽고 간편한 알바 관리',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const Spacer(), // 하단 여백을 위한 공간
          
          // 시작하기 버튼
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  // 버튼 클릭 시 회원가입 첫 단계로 이동
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
          
          // 로그인 링크 섹션
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
            children: [
              const Text(
                '이미 계정이 있으신가요? ',
                style: TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: () {
                  // 로그인 버튼 클릭 시 로그인 화면으로 이동
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
          const SizedBox(height: 20), // 하단 여백
        ],
      ),
    );
  }
}
