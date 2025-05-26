import 'package:albamate_sample/screen/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/component/home_navigation_boss.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BossMypage extends StatefulWidget {
  const BossMypage({super.key});

  @override
  State<BossMypage> createState() => _BossMypageState();
}

class _BossMypageState extends State<BossMypage> {
  final TextEditingController emailController = TextEditingController();

  String? userName;
  String? userRole;
  bool isEditing = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  // Firestore에서 사용자 정보 불러오기
  Future<void> loadUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? '';
          userRole = userDoc['role'] ?? '';
          emailController.text = userDoc['email'] ?? '';
          isLoading = false;
        });
      }
    }
  }

  // 프로필 저장 (이메일 변경)
  void saveProfileChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    final newEmail = emailController.text.trim();

    if (user == null) return;

    try {
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null || !refreshedUser.emailVerified) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이메일 인증이 완료되지 않았습니다.')));
        return;
      }

      await refreshedUser.verifyBeforeUpdateEmail(newEmail);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(refreshedUser.uid)
          .update({'email': newEmail});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 이메일로 인증 메일을 보냈습니다. 인증 후 변경이 완료됩니다.')),
      );

      setState(() => isEditing = false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        showReauthDialog(newEmail);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('에러: ${e.message}')));
      }
    }
  }

  // 이메일 변경 시 재인증 다이얼로그
  void showReauthDialog(String newEmail) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('재인증 필요'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('보안을 위해 비밀번호를 다시 입력해주세요.'),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final password = passwordController.text.trim();
                  final user = FirebaseAuth.instance.currentUser;

                  if (user != null && password.isNotEmpty) {
                    final credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: password,
                    );

                    try {
                      await user.reauthenticateWithCredential(credential);
                      emailController.text = newEmail;
                      saveProfileChanges();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('재인증 실패: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  // 로그아웃 다이얼로그
  void confirmLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              '로그아웃 하시겠어요?',
              style: TextStyle(fontSize: 16), // ✅ 여기서 크기 조절
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                  );
                },
                child: const Text('로그아웃'),
              ),
            ],
          ),
    );
  }

  // 회원 탈퇴 다이얼로그
  void withdrawAccount() {
    final safeContext = context;

    showDialog(
      context: safeContext,
      builder:
          (_) => AlertDialog(
            title: const Text('정말 탈퇴하시겠어요?'),
            content: const Text('탈퇴 시 모든 정보가 삭제되며 복구할 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(safeContext).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(safeContext).pop();
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    final idToken = await user?.getIdToken();

                    final response = await http.post(
                      Uri.parse(
                        'https://backend-vgbf.onrender.com/delete-account',
                      ),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $idToken',
                      },
                      body: jsonEncode({'uid': user?.uid}),
                    );

                    if (response.statusCode == 200) {
                      await FirebaseAuth.instance.signOut();
                      if (!safeContext.mounted) return;
                      Navigator.of(safeContext).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const OnboardingScreen(),
                        ),
                        (route) => false,
                      );
                    } else {
                      final msg =
                          jsonDecode(response.body)['message'] ?? '알 수 없는 오류';
                      if (!safeContext.mounted) return;
                      ScaffoldMessenger.of(
                        safeContext,
                      ).showSnackBar(SnackBar(content: Text('탈퇴 실패: $msg')));
                    }
                  } catch (e) {
                    if (!safeContext.mounted) return;
                    ScaffoldMessenger.of(
                      safeContext,
                    ).showSnackBar(SnackBar(content: Text('탈퇴 중 오류 발생: $e')));
                  }
                },
                child: const Text('탈퇴하기', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        automaticallyImplyLeading: false,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로필 상단 - 사진 + 이름
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          '$userName 님',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 이메일
                    const Text(
                      '이메일',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      enabled: isEditing,
                      decoration: const InputDecoration(
                        hintText: '이메일 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 직책
                    const Text(
                      '직책',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        userRole ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 프로필 수정 / 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isEditing) {
                            saveProfileChanges();
                          } else {
                            setState(() => isEditing = true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006FFD),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(isEditing ? '저장하기' : '프로필 수정'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),

                    // 로그아웃 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton(
                        onPressed: confirmLogout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF006FFD),
                          side: const BorderSide(color: Color(0xFF006FFD)),
                        ),
                        child: const Text('로그아웃'),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 탈퇴 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: TextButton(
                        onPressed: withdrawAccount,
                        child: const Text(
                          '탈퇴하기',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: const HomeNavigationBoss(currentIndex: 2),
    );
  }
}
