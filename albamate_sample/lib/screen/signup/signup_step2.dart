import 'package:flutter/material.dart';
import 'signup_step3.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<void> _proceedToNextStep() async {
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        statusMessage = '비밀번호를 입력해주세요.';
      });
      return;
    }

    // ✅ Node.js 서버에 비밀번호 형식 검사 요청
    final response = await http.post(
      Uri.parse('https://backend-vgbf.onrender.com/auth/check-password'), // 🟡 여기에 Render 서버 주소 입력
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'password': password}),
    );

    final result = jsonDecode(response.body);

    // ✅ 서버 응답 기반으로 검사
    if (!result['valid']) {
      setState(() {
        statusMessage = result['message'] ?? '비밀번호 형식이 올바르지 않습니다.';
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
