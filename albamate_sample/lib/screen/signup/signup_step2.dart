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
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _proceedToNextStep() async {
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        statusMessage = '비밀번호를 입력해주세요.';
      });
      return;
    }

    final response = await http.post(
      Uri.parse('https://backend-vgbf.onrender.com/auth/check-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'password': password}),
    );

    final result = jsonDecode(response.body);

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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "비밀번호는 8자 이상, 영문자, 숫자, 특수문자를 각각 하나 이상 포함해야 합니다.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: '비밀번호',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20.0,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20.0),
                      onPressed: () {
                        setState(() {
                          passwordController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20.0,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20.0),
                      onPressed: () {
                        setState(() {
                          confirmPasswordController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
