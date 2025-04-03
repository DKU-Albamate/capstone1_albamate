import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_step2.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  String statusMessage = '';

  void _checkEmail() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        statusMessage = '이메일을 입력해주세요.';
      });
      return;
    }

    try {
      // Firestore에서 이메일 확인
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await user.reload(); // 인증 상태 최신화
          if (user.emailVerified) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPasswordScreen(email: email),
              ),
            );
          } else {
            setState(() {
              statusMessage = '이메일 인증이 필요합니다.';
            });
          }
        } else {
          setState(() {
            statusMessage = '로그인이 필요합니다.';
          });
        }
      } else {
        setState(() {
          statusMessage = '등록되지 않은 이메일입니다.';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = '오류 발생: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "이메일 입력"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _checkEmail, child: const Text("다음")),
            const SizedBox(height: 10),
            Text(statusMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
