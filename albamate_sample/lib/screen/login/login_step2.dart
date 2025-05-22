import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../homePage/boss/boss_homeCalendar.dart';
import '../homePage/worker/worker_homecalendar.dart';
import 'findpw.dart';

class LoginPasswordScreen extends StatefulWidget {
  final String email;

  const LoginPasswordScreen({super.key, required this.email});

  @override
  _LoginPasswordScreenState createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  String statusMessage = '';
  bool _obscurePassword = true;

  bool get isPasswordValid => passwordController.text.isNotEmpty;

  void _login() async {
    setState(() {
      statusMessage = '';
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: widget.email,
            password: passwordController.text.trim(),
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
          });
        }
      } else {
        setState(() {
          statusMessage = '사용자 정보를 찾을 수 없습니다.';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = '비밀번호가 올바르지 않습니다.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordError = statusMessage == '비밀번호가 올바르지 않습니다.';

    return Scaffold(
      appBar: AppBar(
        title: const Text("로그인"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 2 / 2,
            backgroundColor: Colors.grey[300],
            color: const Color(0xFF006FFD),
            minHeight: 4,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    // 안내 문구
                    const Text("비밀번호를 입력해주세요", style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 24),

                    // 비밀번호 입력 필드
                    TextField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      obscureText: _obscurePassword,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "비밀번호",
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle: const TextStyle(
                          color: Color(0xFF006FFD),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                isPasswordValid && passwordFocusNode.hasFocus
                                    ? Colors.black
                                    : Colors.grey,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
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
                    const SizedBox(height: 32),

                    // 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isPasswordValid ? _login : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isPasswordValid
                                  ? const Color(0xFF006FFD)
                                  : Colors.grey,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text(
                          "로그인",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    // 상태 메시지 - 버튼 아래 가운데 정렬
                    if (statusMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text(
                            statusMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 비밀번호 오류 시 하단 재설정 안내
            if (isPasswordError)
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
                          style: TextStyle(color: Color(0xFF006FFD)),
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
