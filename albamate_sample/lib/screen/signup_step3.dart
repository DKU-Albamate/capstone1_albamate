import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignupStep3 extends StatefulWidget {
  final String email;
  final String password;

  const SignupStep3({super.key, required this.email, required this.password});

  @override
  State<SignupStep3> createState() => _SignupStep3State();
}

class _SignupStep3State extends State<SignupStep3> {
  final TextEditingController nameController = TextEditingController();
  String? selectedRole;
  String statusMessage = '';

  Future<void> _signUpAndSaveData() async {
    if (nameController.text.trim().isEmpty || selectedRole == null) {
      setState(() {
        statusMessage = '이름과 직책을 모두 입력해주세요.';
      });
      return;
    }

    try {
      // Firebase Authentication에서 사용자 생성
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );

      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(nameController.text);
        await user.sendEmailVerification();

        // Firestore에 사용자 정보 저장
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': widget.email,
          'name': nameController.text,
          'role': selectedRole,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 회원가입 성공 메시지 및 로그인 화면으로 이동
        setState(() {
          statusMessage = '회원가입 성공! 이메일 인증 후 로그인 화면으로 이동합니다.';
        });

        // 로그인 페이지로 이동
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(
            context,
            '/login',
          ); // '/login'은 로그인 화면의 라우트 이름
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = '회원가입 실패: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입 - Step 3")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "이름"),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
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
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signUpAndSaveData,
              child: const Text("회원가입 완료"),
            ),
            const SizedBox(height: 10),
            if (statusMessage.isNotEmpty)
              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.green, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
