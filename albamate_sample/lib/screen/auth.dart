import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginView = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  String statusMessage = ''; // 상태 메시지 저장

  void _authenticate() {
    setState(() {
      statusMessage = ''; // 초기화
    });

    if (isLoginView) {
      // 로그인 로직
      FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text,
            password: pwdController.text,
          )
          .catchError((e) {
            setState(() {
              statusMessage = '로그인 실패: ${e.message}';
            });
          })
          .then((value) {
            setState(() {
              statusMessage = '로그인 성공!';
            });
          });
    } else {
      // 회원가입 로직
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text,
            password: pwdController.text,
          )
          .catchError((e) {
            setState(() {
              if (e.code == 'weak-password') {
                statusMessage = '비밀번호 보안이 약합니다.';
              } else if (e.code == 'email-already-in-use') {
                statusMessage = '이미 사용 중인 이메일입니다.';
              } else {
                statusMessage = '회원가입 실패: ${e.message}';
              }
            });
          })
          .then((value) {
            setState(() {
              emailController.clear();
              pwdController.clear();
              statusMessage = '회원가입 성공!';
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('인증')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pwdController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: Text(isLoginView ? '로그인' : '회원가입'),
            ),
            const SizedBox(height: 10),
            Text(
              statusMessage,
              style: const TextStyle(color: Colors.green, fontSize: 16),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  isLoginView = !isLoginView;
                  statusMessage = '';
                });
              },
              child: Text(
                isLoginView ? '회원가입하기' : '로그인하기',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
