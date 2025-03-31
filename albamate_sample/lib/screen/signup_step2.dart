import 'package:flutter/material.dart';
import 'signup_step3.dart';

class SignupStep2 extends StatefulWidget {
  final String email;

  const SignupStep2({super.key, required this.email});

  @override
  State<SignupStep2> createState() => _SignupStep2State();
}

class _SignupStep2State extends State<SignupStep2> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String statusMessage = '';

  void _proceedToNextStep() {
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        statusMessage = '비밀번호를 입력해주세요.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        statusMessage = '비밀번호와 확인 비밀번호가 일치하지 않습니다.';
      });
      return;
    }

    // 다음 단계(Step 3)로 이동, 이메일과 비밀번호 전달
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SignupStep3(email: widget.email, password: password),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입 - Step 2")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호 확인'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _proceedToNextStep,
              child: const Text('다음 단계'),
            ),
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
