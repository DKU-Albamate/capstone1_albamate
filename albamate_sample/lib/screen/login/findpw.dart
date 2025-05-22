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

  bool get isValid =>
      emailController.text.isNotEmpty &&
      nameController.text.isNotEmpty &&
      selectedRole != null &&
      newPasswordController.text.isNotEmpty &&
      confirmPasswordController.text.isNotEmpty;

  void _changePassword() {
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
