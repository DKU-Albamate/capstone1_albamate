import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_step2.dart';
import '../signup/signup_step1.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode(); // 포커스 추적
  String statusMessage = '';

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

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
        // Firestore에 있으면 비밀번호 입력 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPasswordScreen(email: email),
          ),
        );
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
    final isEmailValid = emailController.text.trim().isNotEmpty;
    final isUnregisteredEmail = statusMessage == '등록되지 않은 이메일입니다.';

    return Scaffold(
      appBar: AppBar(
        title: const Text("로그인"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 1 / 2,
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
                  crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                  children: [
                    const SizedBox(height: 48),

                    // 안내 문구
                    const Text(
                      "로그인에 사용할 이메일을 입력해주세요",
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 24),

                    // 이메일 입력 필드
                    TextField(
                      controller: emailController,
                      focusNode: emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "이메일",
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle: const TextStyle(
                          color: Color(0xFF006FFD),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                isEmailValid && emailFocusNode.hasFocus
                                    ? Colors.black
                                    : Colors.grey,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              emailController.clear();
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 다음 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isEmailValid ? _checkEmail : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isEmailValid
                                  ? const Color(0xFF006FFD)
                                  : Colors.grey,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text(
                          "다음",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 상태 메시지: 버튼 바로 아래
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

            // 하단: 회원가입 안내는 등록되지 않은 이메일일 때만 표시
            if (isUnregisteredEmail)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '계정이 없으신가요? ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const SignupStep1(email: ''),
                            ),
                          );
                        },
                        child: const Text(
                          '회원가입',
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
