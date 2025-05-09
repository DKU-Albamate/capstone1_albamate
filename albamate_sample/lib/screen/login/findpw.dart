import 'package:flutter/material.dart';

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

    setState(() {
      resultMessage = '※ 백엔드에서 정보 확인 후 비밀번호를 변경할 예정입니다.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 재설정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),
              const Text(
                '비밀번호는 8자 이상, 영문자, 숫자, 특수문자를 포함해야 합니다.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: '새 비밀번호',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20.0,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20.0),
                        onPressed: () {
                          setState(() {
                            newPasswordController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20.0,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
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
              Center(
                child: ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text('비밀번호 재설정'),
                ),
              ),
              const SizedBox(height: 10),
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
