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
  final FocusNode nameFocusNode = FocusNode(); // 포커스 감지
  String? selectedRole;
  String statusMessage = '';

  // 이름과 직책 입력 후 Firebase Auth + Firestore 저장
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

        // 성공 메시지 출력
        setState(() {
          statusMessage = '회원가입 성공! 이메일 인증 후 로그인 화면으로 이동합니다.';
        });

        // 로그인 화면으로 2초 후 이동
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = '회원가입 실패: ${e.toString()}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    nameFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInputComplete =
        nameController.text.trim().isNotEmpty && selectedRole != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입"), // 앱바 텍스트
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 3 / 3, // Step 3/3
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
            const SizedBox(height: 40),
            // 이름 입력 필드
            TextField(
              controller: nameController,
              focusNode: nameFocusNode,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: "이름",
                labelStyle: TextStyle(color: Colors.grey), // 기본 상태 색상
                floatingLabelStyle: TextStyle(color: const Color(0xFF006FFD)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        nameController.text.isNotEmpty && nameFocusNode.hasFocus
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
                      nameController.clear();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 직책 선택 드롭다운
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedRole != null ? Colors.black : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRole,
                  hint: const Text(
                    "직책 선택",
                    style: TextStyle(color: Colors.grey), // 선택 전 텍스트 색상
                  ),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.black), // 선택 후 텍스트 색상
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
              ),
            ),

            const SizedBox(height: 36),

            // 버튼 (Step1과 동일 디자인)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isInputComplete ? _signUpAndSaveData : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isInputComplete ? const Color(0xFF006FFD) : Colors.grey,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  "회원가입 완료",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 상태 메시지 출력
            if (statusMessage.isNotEmpty)
              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      statusMessage.startsWith('회원가입 성공')
                          ? Colors.green
                          : Colors.red,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
