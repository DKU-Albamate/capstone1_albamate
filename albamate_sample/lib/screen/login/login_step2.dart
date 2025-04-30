import 'package:flutter/material.dart'; // Flutter UI 구성 요소
import 'package:firebase_auth/firebase_auth.dart'; // Firebase 인증 기능
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore DB 접근
import '../homePage/boss/boss_homeCalendar.dart'; // 사장님 홈 캘린더
import '../homePage/worker/worker_homecalendar.dart'; // 알바생 홈 캘린더
import 'findpw.dart';

// 로그인 두 번째 단계 - 비밀번호 입력 화면
class LoginPasswordScreen extends StatefulWidget {
  final String email; // 이전 화면에서 전달된 이메일

  const LoginPasswordScreen({super.key, required this.email});

  @override
  _LoginPasswordScreenState createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  // 비밀번호 입력 필드 컨트롤러
  TextEditingController passwordController = TextEditingController();

  // 상태 메시지와 비밀번호 실패 여부를 위한 변수
  String statusMessage = '';
  bool loginFailed = false; // 비밀번호 실패 여부 저장

  // 로그인 로직 함수
  void _login() async {
    setState(() {
      statusMessage = '';
      loginFailed = false; // 초기화
    });

    try {
      // Firebase 인증 처리
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: widget.email, // 전달된 이메일 사용
            password: passwordController.text, // 입력한 비밀번호 사용
          );

      // Firestore에서 해당 유저 문서 가져오기
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (userDoc.exists) {
        String role = userDoc['role'];
        // 사장님이면 사장님 화면으로 이동
        if (role == '사장님') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BossHomecalendar()),
          );
        }
        // 알바생이면 알바생 화면으로 이동
        else if (role == '알바생') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WorkerPage()),
          );
        } else {
          // 직책이 비정상일 때
          setState(() {
            statusMessage = '올바르지 않은 직책입니다.';
            loginFailed = true;
          });
        }
      } else {
        // Firestore에 사용자 정보가 없는 경우
        setState(() {
          statusMessage = '사용자 정보를 찾을 수 없습니다.';
          loginFailed = true;
        });
      }
    } catch (e) {
      // 로그인 실패 (예: 비밀번호 오류 등)
      setState(() {
        statusMessage = '비밀번호가 올바르지 않습니다.'; // ✅ 사용자 친화적인 메시지
        loginFailed = true; // 실패 상태 true로 설정
      });
    }
  }

  // UI 빌드
  @override
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
                  // 비밀번호 입력 필드
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "비밀번호 입력"),
                  ),
                  const SizedBox(height: 20),
                  // 로그인 버튼
                  ElevatedButton(onPressed: _login, child: const Text("로그인")),
                  const SizedBox(height: 10),
                  // 상태 메시지 표시
                  Text(
                    statusMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            // 비밀번호 재설정 링크 섹션
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
