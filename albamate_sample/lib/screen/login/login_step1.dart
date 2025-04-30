import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_step2.dart';
import '../signup/signup_step1.dart';

// 로그인 첫 단계 - 이메일 입력 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  String statusMessage = '';

  // 이메일 존재 여부 확인 함수
  void _checkEmail() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        statusMessage = '이메일을 입력해주세요.';
      });
      return;
    }

    try {
      // Firestore에서 이메일 확인
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // 이메일이 존재하면 바로 비밀번호 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPasswordScreen(email: email),
          ),
        );
      } else {
        setState(() {
          statusMessage = '등록되지 않은 이메일입니다.';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = '오류 발생: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 이메일 입력 필드
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "이메일 입력"),
                  ),
                  const SizedBox(height: 12),
                  // 다음 버튼
                  ElevatedButton(
                    onPressed: _checkEmail,
                    child: const Text("다음"),
                  ),
                  const SizedBox(height: 10),
                  // 상태 메시지 표시
                  Text(
                    statusMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            // 회원가입 링크 섹션
            if (statusMessage == '등록되지 않은 이메일입니다.')
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '계정이 없으신가요? ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const SignupStep1(email: ''),
                            ),
                          );
                        },
                        child: const Text(
                          '회원가입',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
