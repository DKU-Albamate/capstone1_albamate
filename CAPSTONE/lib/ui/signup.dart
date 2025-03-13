import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selectedRole = "알바생"; // 기본값: 알바생
  File? _businessLicenseFile; // 사장님 사업자 등록증 첨부 파일

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _businessLicenseFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "회원가입",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // 사용자 역할 선택 (사장님 or 알바생)
              DropdownButtonFormField<String>(
                value: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                items:
                    ["사장님", "알바생"].map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                decoration: const InputDecoration(
                  labelText: "회원 유형 선택",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // 이메일 입력 필드
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "이메일",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "이메일을 입력하세요.";
                  }
                  if (!RegExp(
                    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                  ).hasMatch(value)) {
                    return "올바른 이메일 형식이 아닙니다.";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // 비밀번호 입력 필드
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "비밀번호",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "비밀번호를 입력하세요.";
                  }
                  if (value.length < 6) {
                    return "비밀번호는 6자리 이상이어야 합니다.";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // 비밀번호 확인 필드
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: "비밀번호 확인",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return "비밀번호가 일치하지 않습니다.";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // 사장님일 경우 사업자 등록증 업로드 버튼 표시
              if (_selectedRole == "사장님") ...[
                const Text(
                  "사업자 등록증 업로드",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: const Text("파일 선택"),
                ),
                if (_businessLicenseFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "선택된 파일: ${_businessLicenseFile!.path.split('/').last}",
                    ),
                  ),
                const SizedBox(height: 15),
              ],

              // 회원가입 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedRole == "사장님" &&
                          _businessLicenseFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("사장님은 사업자 등록증을 첨부해야 합니다."),
                          ),
                        );
                        return;
                      }
                      // 🚀 Firebase 회원가입 로직 추가 예정
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("$_selectedRole 회원가입 처리 중...")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // 버튼 색상
                    foregroundColor: Colors.white, // 글자 색상
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("회원가입", style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 15),

              // 로그인 화면으로 이동
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    "이미 계정이 있나요? 로그인",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
