import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_step2.dart'; // 수정된 부분 (step2로 이동)
import '../login/login_step1.dart'; // 로그인 화면 import

// 이메일 입력 화면 (회원가입 Step1)
// 1. 앱바 텍스트 수정 ("회원가입")
// 2. 앱바 하단에 LinearProgressIndicator 추가 (회원가입 진행 상황 1/3 단계)
// 3. 이메일 입력 안내 문구 추가
// 4. 텍스트 필드: 입력 전에는 회색, 입력 중에는 검정 강조
// 5. 버튼: 입력 전에는 비활성화(회색), 입력 시 파란색 활성화
// 6. 버튼 텍스트를 "다음"으로 변경
// 7. 버튼 스타일은 "시작하기" 버튼과 동일한 디자인 유지

class SignupStep1 extends StatefulWidget {
  const SignupStep1({super.key, required String email});

  @override
  State<SignupStep1> createState() => _SignupStep1State();
}

class _SignupStep1State extends State<SignupStep1> {
  TextEditingController emailController =
      TextEditingController(); // 이메일 입력 컨트롤러
  FocusNode emailFocusNode = FocusNode(); // 포커스 상태 감지용 포커스 노드 추가
  String statusMessage = ''; // 오류 또는 상태 메시지 저장
  bool isTyping = false; // 입력 중 여부 판단

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(() {
      setState(() {}); // 포커스 상태 변경 시 UI 갱신
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose(); // 포커스 노드 해제
    super.dispose();
  }

  // 이메일 입력 후 존재 여부 확인
  void _checkEmail() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        statusMessage = '이메일을 입력해주세요.';
      });
      return;
    }

    try {
      // Firestore에서 이메일 존재 여부 확인
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // 이메일이 이미 존재하면 로그인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        // 이메일이 존재하지 않으면 비밀번호 설정 화면으로 이동 (SignupStep2)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignupStep2(email: email), // step2로 이동
          ),
        );
      }
    } catch (e) {
      setState(() {
        statusMessage = '오류 발생: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmailValid = emailController.text.trim().isNotEmpty; // 입력값 유효성 판단

    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입"), // 앱바 텍스트 수정
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 1 / 3, // 회원가입 3단계 중 현재 1단계 진행률 표시
            backgroundColor: Colors.grey[300],
            color: const Color(0xFF006FFD), // 파란색 진행 표시
            minHeight: 4,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // 이메일 입력 안내 문구 추가
            const Text('로그인에 사용할 이메일을 입력해주세요', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            // 이메일 입력 필드
            TextField(
              controller: emailController,
              focusNode: emailFocusNode, // ✅ 포커스 노드 연결
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) {
                setState(() {
                  isTyping = true; // 입력 중 플래그 활성화
                });
              },
              decoration: InputDecoration(
                labelText: '이메일',
                labelStyle: TextStyle(color: Colors.grey), // 기본 상태 색상
                floatingLabelStyle: TextStyle(
                  color: const Color(0xFF006FFD),
                ), // 포커스 상태에서 작아져서 떠 있는 라벨 색상
                hintText: 'example@email.com',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    // 입력 전 또는 포커스 아웃 시 회색, 입력 + 포커스 시 검정
                    color:
                        isEmailValid && emailFocusNode.hasFocus
                            ? Colors.black
                            : Colors.grey,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  // 입력 중: 검정색 강조 테두리
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 다음 버튼 (입력 전에는 회색 비활성화, 입력 후 파란색 활성화)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isEmailValid ? _checkEmail : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isEmailValid ? const Color(0xFF006FFD) : Colors.grey,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  '다음', // 버튼 텍스트 수정
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 상태 메시지 표시 영역 (에러 등)
            if (statusMessage.isNotEmpty)
              Text(statusMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
