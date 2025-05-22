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

  String? selectedRole;
  String resultMessage = '';
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool get isValid =>
      emailController.text.isNotEmpty &&
      nameController.text.isNotEmpty &&
      selectedRole != null &&
      newPasswordController.text.isNotEmpty &&
      confirmPasswordController.text.isNotEmpty;

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
        Uri.parse('https://backend-vgbf.onrender.com/auth/reset-password'), 
        // 로컬에서 테스트 하려면 http://localhost:3000/auth/reset-password 넣으시면 됩니다. 
        // 배포용은 https://backend-vgbf.onrender.com/auth/reset-password, 
        // VSCode에서 Android Studio로 테스트 할려면 http://10.0.2.2:3000/auth/reset-password로 변경
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'name': name,
          'role': role,
          'newPassword': newPassword,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          resultMessage = responseData['message'] ?? '비밀번호가 성공적으로 변경되었습니다.';
        });
        
        // 성공 시 로그인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPasswordScreen(email: email)),
        );
      } else {
        try {
          final error = json.decode(response.body);
          setState(() {
            resultMessage = error['message'] ?? '비밀번호 변경에 실패했습니다.';
          });
        } catch (e) {
          setState(() {
            resultMessage = '서버 응답 형식이 올바르지 않습니다. 다시 시도해주세요.';
          });
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        resultMessage = '서버 연결에 실패했습니다. 다시 시도해주세요.';
      });
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: Color(0xFF006FFD)),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 재설정')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              TextField(
                controller: emailController,
                decoration: _buildInputDecoration('이메일'),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: nameController,
                decoration: _buildInputDecoration('이름'),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedRole,
                isExpanded: true,
                hint: const Text("직책 선택", style: TextStyle(color: Colors.grey)),
                decoration: _buildInputDecoration(''),
                items:
                    ['알바생', '사장님'].map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                onChanged: (value) => setState(() => selectedRole = value),
              ),

              const SizedBox(height: 24),

              const Text(
                '비밀번호는 8자 이상, 영문자, 숫자, 특수문자를 포함해야 합니다.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: _buildInputDecoration('새 비밀번호').copyWith(
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed:
                            () => setState(
                              () => _obscureNewPassword = !_obscureNewPassword,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed:
                            () => setState(() => newPasswordController.clear()),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: _buildInputDecoration('비밀번호 확인').copyWith(
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed:
                            () => setState(
                              () =>
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed:
                            () => setState(
                              () => confirmPasswordController.clear(),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isValid ? _changePassword : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isValid ? const Color(0xFF006FFD) : Colors.grey,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text(
                    '비밀번호 재설정',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              if (resultMessage.isNotEmpty)
                Center(
                  child: Text(
                    resultMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
