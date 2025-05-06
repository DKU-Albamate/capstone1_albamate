import 'package:albamate_sample/screen/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../component/home_navigation_worker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WorkerMyPage extends StatefulWidget {
  const WorkerMyPage({super.key});

  @override
  State<WorkerMyPage> createState() => _WorkerMyPageState();
}

class _WorkerMyPageState extends State<WorkerMyPage> {
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

  void saveProfileChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    final newEmail = emailController.text.trim();

    if (user == null) return;

    try {
      // 인증 상태 새로고침
      await user.reload();


      // ✅ 새로고침 후 최신 사용자 객체 다시 참조
      final refreshedUser = FirebaseAuth.instance.currentUser;
      print('[디버그] 현재 이메일: ${refreshedUser?.email}');
      print('[디버그] 인증 여부: ${refreshedUser?.emailVerified}');

      if (refreshedUser == null || !refreshedUser.emailVerified) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이메일 인증이 완료되지 않았습니다.')),
        );
        return;
      }

      // 이메일 변경 시도
      await refreshedUser.verifyBeforeUpdateEmail(newEmail);

      // Firestore에서도 이메일 동기화
      await FirebaseFirestore.instance
          .collection('users')
          .doc(refreshedUser.uid)
          .update({'email': newEmail});

      //새 이메일 인증 완료 전까지는 기존 이메일 그대로 유지됨
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('새 이메일로 인증 메일을 보냈습니다. 인증 후 변경이 완료됩니다.')),
      );

      setState(() => isEditing = false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // 재인증이 필요한 경우 다이얼로그 띄움
        showReauthDialog(newEmail);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('에러: ${e.message}')),
        );
      }
    }
  }



  void showReauthDialog(String newEmail) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('재인증 필요'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('보안을 위해 비밀번호를 다시 입력해주세요.'),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
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
                  // 재인증 시도
                  await user.reauthenticateWithCredential(credential);

                  // 재인증 성공 시 이메일 변경 재시도
                  emailController.text = newEmail;
                  saveProfileChanges(); // 자동 재시도

                } catch (e) {
                  if (!mounted) return; //
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('재인증 실패: ${e.toString()}')),
                  );
                }
              }
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }


  void confirmLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('로그아웃 하시겠어요?'),
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

  void withdrawAccount() {
    final safeContext = context; //  context 미리 저장

    showDialog(
      context: safeContext,
      builder: (_) => AlertDialog(
        title: Text('정말 탈퇴하시겠어요?'),
        content: Text('탈퇴 시 모든 정보가 삭제되며 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(safeContext).pop(),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(safeContext).pop(); // 다이얼로그 먼저 닫음

              try {
                final user = FirebaseAuth.instance.currentUser;
                final idToken = await user?.getIdToken();

                final response = await http.post(
                  Uri.parse('https://backend-vgbf.onrender.com/delete-account'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $idToken',
                  },
                  body: jsonEncode({'uid': user?.uid}),
                );

                if (response.statusCode == 200) {
                  await FirebaseAuth.instance.signOut();

                  // ✅ 탈퇴 후 온보딩으로 이동
                  if (!safeContext.mounted) return;
                  Navigator.of(safeContext).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => OnboardingScreen()),
                        (route) => false,
                  );
                } else {
                  final msg = jsonDecode(response.body)['message'] ?? '알 수 없는 오류';
                  if (!safeContext.mounted) return;
                  ScaffoldMessenger.of(safeContext).showSnackBar(
                    SnackBar(content: Text('탈퇴 실패: $msg')),
                  );
                }
              } catch (e) {
                if (!safeContext.mounted) return;
                ScaffoldMessenger.of(safeContext).showSnackBar(
                  SnackBar(content: Text('탈퇴 중 오류 발생: $e')),
                );
              }
            },
            child: Text('탈퇴하기', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 프로필 상단
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
                    const SizedBox(height: 30),

                    /// 이메일
                    const Text(
                      '이메일',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      enabled: isEditing,
                      decoration: const InputDecoration(hintText: '이메일 입력'),
                    ),
                    const SizedBox(height: 20),

                    /// 직책
                    const Text(
                      '직책',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    const SizedBox(height: 30),

                    /// 수정 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isEditing) {
                            saveProfileChanges();
                          } else {
                            setState(() => isEditing = true);
                          }
                        },
                        child: Text(isEditing ? '저장하기' : '프로필 수정'),
                      ),
                    ),

                    const SizedBox(height: 40),
                    const Divider(),

                    /// 로그아웃 / 탈퇴
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: confirmLogout,
                        child: const Text('로그아웃'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: withdrawAccount,
                        child: const Text(
                          '탈퇴하기',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: const HomeNavigationWorker(currentIndex: 2),
    );
  }
}
