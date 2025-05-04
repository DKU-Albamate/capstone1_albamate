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

    // ↓ 백엔드에서 Firestore 정보(email, name, role) 확인 후 비밀번호 변경
    // 1. Firestore에서 해당 정보로 유저 조회
    // 2. Firebase Authentication에서 해당 계정의 비밀번호를 newPassword로 변경
    // 3. 성공/실패에 따라 아래 메시지 표시

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
