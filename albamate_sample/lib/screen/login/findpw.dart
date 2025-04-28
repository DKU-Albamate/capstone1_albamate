import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_step2.dart';

class FindPWScreen extends StatefulWidget {
  const FindPWScreen({super.key});

  @override
  State<FindPWScreen> createState() => _FindPWScreenState();
}

class _FindPWScreenState extends State<FindPWScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? selectedRole; // 선택된 직책
  String resultMessage = '';

  void _changePassword() async {
    final email = emailController.text.trim();
    final name = nameController.text.trim();
    final role = selectedRole;
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if ([
      email,
      name,
      role,
      newPassword,
      confirmPassword,
    ].any((e) => e == null || e.isEmpty)) {
      setState(() {
        resultMessage = '모든 필드를 입력해주세요.';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        resultMessage = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }

    try {
      // 백엔드 API 호출
      final response = await http.post(
        Uri.parse('https://backend-vgbf.onrender.com:3000/auth/reset-password'), // 로컬에서 테스트 하려면 http://localhost:3000/auth/reset-password 넣으시면 됩니다.
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'name': name,
          'role': role,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          resultMessage = '비밀번호가 성공적으로 변경되었습니다.';
        });
        
        // 성공 시 로그인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPasswordScreen(email: email)),
        );
      } else {
        final error = json.decode(response.body);
        setState(() {
          resultMessage = error['message'] ?? '비밀번호 변경에 실패했습니다.';
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        resultMessage = '서버 연결에 실패했습니다. 다시 시도해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 재설정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: '이메일'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '이름'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedRole,
                hint: const Text("직책 선택"),
                items:
                    ["알바생", "사장님"].map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '새 비밀번호'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '비밀번호 확인'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text('비밀번호 재설정'),
              ),
              const SizedBox(height: 10),
              Text(resultMessage, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
