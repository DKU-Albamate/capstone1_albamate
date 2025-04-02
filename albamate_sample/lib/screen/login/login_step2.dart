import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../homePage/boss/boss_homeCalendar.dart';
import '../homePage/worker/worker_homecalendar.dart';

class LoginPasswordScreen extends StatefulWidget {
  final String email;

  const LoginPasswordScreen({super.key, required this.email});

  @override
  _LoginPasswordScreenState createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  String statusMessage = '';

  void _login() async {
    setState(() {
      statusMessage = '';
    });

    try {
      // Firebase Authentication 로그인
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: widget.email,
            password: passwordController.text,
          );

      // Firestore에서 직책(role) 정보 가져오기
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (userDoc.exists) {
        String role = userDoc['role'];
        if (role == '사장님') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BossHomecalendar()),
          );
        } else if (role == '알바생') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WorkerPage()),
          );
        } else {
          setState(() {
            statusMessage = '올바르지 않은 직책입니다.';
          });
        }
      } else {
        setState(() {
          statusMessage = '사용자 정보를 찾을 수 없습니다.';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = '로그인 실패: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("비밀번호 입력")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "비밀번호 입력"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("로그인")),
            const SizedBox(height: 10),
            Text(statusMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
