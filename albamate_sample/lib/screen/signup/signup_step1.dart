import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_step2.dart'; // 수정된 부분 (step2로 이동)
import '../login/login_step1.dart';

class SignupStep1 extends StatefulWidget {
  const SignupStep1({super.key, required String email});

  @override
  State<SignupStep1> createState() => _SignupStep1State();
}

class _SignupStep1State extends State<SignupStep1> {
  TextEditingController emailController = TextEditingController();
  String statusMessage = '';

  /// ✅ 이메일 입력 후 존재 여부 확인
  void _checkEmail() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        statusMessage = '이메일을 입력해주세요.';
      });
      return;
    }

    try {
      // Firestore에서 이메일 존재 여부 확인
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // 이메일이 이미 존재하면 로그인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        // 이메일이 존재하지 않으면 비밀번호 설정 화면으로 이동 (SignupStep2)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignupStep2(email: email), // step2로 이동
          ),
        );
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
      appBar: AppBar(title: const Text("회원가입 - Step 1")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '이메일',
                hintText: '이메일을 입력하세요',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _checkEmail, child: const Text('이메일 확인')),
            const SizedBox(height: 10),
            if (statusMessage.isNotEmpty)
              Text(
                statusMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
