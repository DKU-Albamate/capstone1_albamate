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
  final FocusNode passwordFocusNode = FocusNode(); // 포커스 상태
  final FocusNode confirmFocusNode = FocusNode();

  String statusMessage = ''; // 에러 메시지
  bool _obscurePassword = true; // 비밀번호 숨김 상태
  bool _obscureConfirm = true;
  String _passwordStrength = ''; // 비밀번호 강도 텍스트
  Color _strengthColor = Colors.grey; // 강도 텍스트 색

  @override
  void initState() {
    super.initState();
    passwordFocusNode.addListener(() => setState(() {}));
    confirmFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocusNode.dispose();
    confirmFocusNode.dispose();
    super.dispose();
  }

  // 비밀번호 강도 평가 함수
  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      _passwordStrength = '';
      _strengthColor = Colors.grey;
    } else if (password.length < 8) {
      _passwordStrength = '너무 짧음';
      _strengthColor = Colors.red;
    } else if (RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
    ).hasMatch(password)) {
      _passwordStrength = '보통';
      _strengthColor = Colors.orange;
    } else if (RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$',
    ).hasMatch(password)) {
      _passwordStrength = '강함';
      _strengthColor = Colors.green;
    } else {
      _passwordStrength = '약함';
      _strengthColor = Colors.red;
    }
  }

  // 입력 유효성 및 일치 여부로 버튼 활성화 판단
  bool get _isPasswordValid {
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    final isFormatValid = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*]).{8,}$',
    ).hasMatch(password);

    return isFormatValid && password == confirm;
  }

  // 백엔드와 연동해 비밀번호 유효성 검증
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
    final passwordText = passwordController.text.trim();
    _checkPasswordStrength(passwordText); // 비밀번호 강도 실시간 계산

    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입"), // 앱바 텍스트 변경
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 2 / 3, // 진행 바 2/3
            backgroundColor: Colors.grey[300],
            color: const Color(0xFF006FFD),
            minHeight: 4,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            // 안내 문구
            const Text(
              "로그인에 사용할 비밀번호를\n입력해주세요",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 12),
            // 조건 설명
            const Text(
              "비밀번호는 8자 이상, 영문자, 숫자, 특수문자를 각각 하나 이상 포함해야 합니다.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 비밀번호 입력 필드
            TextField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              obscureText: _obscurePassword,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: '비밀번호',
                labelStyle: TextStyle(color: Colors.grey), // 기본 상태 색상
                floatingLabelStyle: TextStyle(color: const Color(0xFF006FFD)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        passwordText.isNotEmpty && passwordFocusNode.hasFocus
                            ? Colors.black
                            : Colors.grey,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed:
                          () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed:
                          () => setState(() {
                            passwordController.clear();
                          }),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 4),
            // 비밀번호 강도 표시
            if (_passwordStrength.isNotEmpty)
              Text(
                '  비밀번호 강도: $_passwordStrength',
                style: TextStyle(fontSize: 13, color: _strengthColor),
              ),

            const SizedBox(height: 20),

            // 비밀번호 확인 입력 필드
            TextField(
              controller: confirmPasswordController,
              focusNode: confirmFocusNode,
              obscureText: _obscureConfirm,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                labelStyle: TextStyle(color: Colors.grey), // 기본 상태 색상
                floatingLabelStyle: TextStyle(color: const Color(0xFF006FFD)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        confirmPasswordController.text.isNotEmpty &&
                                confirmFocusNode.hasFocus
                            ? Colors.black
                            : Colors.grey,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed:
                          () => setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          }),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed:
                          () => setState(() {
                            confirmPasswordController.clear();
                          }),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 다음 버튼 (Step1과 동일한 스타일)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isPasswordValid ? _proceedToNextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isPasswordValid ? const Color(0xFF006FFD) : Colors.grey,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('다음', style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 12),

            // 상태 메시지 표시
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
