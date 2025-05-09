import 'package:flutter/material.dart'; // Flutter UI 구성 요소
import 'package:firebase_auth/firebase_auth.dart'; // Firebase 인증 기능
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore DB 접근
import '../homePage/boss/boss_homeCalendar.dart'; // 사장님 홈 캘린더
import '../homePage/worker/worker_homecalendar.dart'; // 알바생 홈 캘린더
import 'findpw.dart';

// Stateful 위젯으로 로그인 비밀번호 화면 정의
class LoginPasswordScreen extends StatefulWidget {
  final String email; // 이전 화면에서 전달된 이메일

  const LoginPasswordScreen({super.key, required this.email});

  @override
  _LoginPasswordScreenState createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  String statusMessage = '';
  bool loginFailed = false;
  bool _obscurePassword = true; // 👈 비밀번호 표시 여부 상태

  // 로그인 로직
  void _login() async {
    setState(() {
      statusMessage = '';
      loginFailed = false;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: widget.email,
            password: passwordController.text,
          );

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
            MaterialPageRoute(builder: (context) => const BossHomecalendar()),
          );
        } else if (role == '알바생') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WorkerHomecalendar()),
          );
        } else {
          setState(() {
            statusMessage = '올바르지 않은 직책입니다.';
            loginFailed = true;
          });
        }
      } else {
        setState(() {
          statusMessage = '사용자 정보를 찾을 수 없습니다.';
          loginFailed = true;
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = '비밀번호가 올바르지 않습니다.';
        loginFailed = true;
      });
    }
  }

  // UI 빌드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("비밀번호 입력")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "비밀번호 입력",
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20.0,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20.0),
                            onPressed: () {
                              setState(() {
                                passwordController.clear();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _login, child: const Text("로그인")),
                  const SizedBox(height: 10),
                  Text(
                    statusMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            if (statusMessage.contains('비밀번호'))
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '비밀번호를 잊으셨나요? ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FindPWScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '비밀번호 재설정',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
