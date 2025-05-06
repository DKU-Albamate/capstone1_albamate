import 'package:albamate_sample/screen/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMyPage extends StatefulWidget {
  const GroupMyPage({super.key});

  @override
  State<GroupMyPage> createState() => _GroupMyPageState();
}

class _GroupMyPageState extends State<GroupMyPage> {
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
    String newEmail = emailController.text.trim();

    // ✅ 백엔드 작업 필요:
    // 1. Firebase Authentication 이메일 업데이트
    // 2. Firestore에서 해당 사용자의 email 필드 업데이트
    // ⚠️ 재로그인 요구될 수 있음

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이메일 변경 요청 완료 (백엔드 작업 필요)')));

    setState(() {
      isEditing = false;
    });
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
    // ✅ 백엔드 작업 필요:
    // 1. Firebase Authentication 사용자 삭제
    // 2. Firestore users 문서 삭제
    // ⚠️ 재로그인 요구될 수 있음

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('탈퇴 기능은 백엔드 구현 후 연결 예정입니다')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Scrollbar(
                // ✅ 스크롤바 추가
                child: SingleChildScrollView(
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
              ),
    );
  }
}
