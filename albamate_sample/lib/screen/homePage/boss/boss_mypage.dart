import 'package:albamate_sample/screen/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/component/home_navigation_boss.dart';

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

    // ✅ 백엔드가 해야 할 일:
    // 1. Firebase Authentication에서 현재 사용자의 이메일 업데이트:
    //    await FirebaseAuth.instance.currentUser?.updateEmail(newEmail);
    //
    // 2. Firestore에서 해당 사용자의 email 필드도 업데이트:
    //    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({ 'email': newEmail });
    //
    // ⚠️ 이메일 업데이트 시 Firebase는 보안 상 재로그인을 요구할 수 있음. 이를 UI/UX로 처리해야 함.

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('이메일 변경 요청 완료 (백엔드 작업 필요)')));

    setState(() {
      isEditing = false;
    });
  }

  void confirmLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('로그아웃 하시겠어요?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // ✅ 백엔드가 해야 할 일:
                  // FirebaseAuth에서 사용자 로그아웃 처리
                  // 예: await FirebaseAuth.instance.signOut();
                  //
                  // 이후 로그인 화면으로 이동

                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => OnboardingScreen()),
                  );
                },
                child: Text('로그아웃'),
              ),
            ],
          ),
    );
  }

  void withdrawAccount() {
    // ✅ 백엔드가 해야 할 일:
    // 1. Firebase Authentication 사용자 계정 삭제
    //    await FirebaseAuth.instance.currentUser?.delete();
    //
    // 2. Firestore의 users 컬렉션에서 해당 사용자 문서 삭제
    //    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
    //
    // ⚠️ 민감한 작업이므로 재로그인 요구될 수 있음.
    //
    // ❗ 프론트엔드에서는 꼭 확인 다이얼로그 추가 + 실수 방지 UX 구현 권장
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('탈퇴 기능은 백엔드 구현 후 연결 예정입니다')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('마이페이지')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 👤 프로필 상단 - 사진 자리 + 이름
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          '$userName 님',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    /// ✉️ 이메일 (수정 가능)
                    Text(
                      '이메일',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      enabled: isEditing,
                      decoration: InputDecoration(hintText: '이메일 입력'),
                    ),
                    SizedBox(height: 20),

                    /// 🧾 직책 (읽기 전용)
                    Text(
                      '직책',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        userRole ?? '',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 30),

                    /// ✏️ 프로필 수정 / 저장 버튼 (전체 가로 너비)
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

                    /// 🔻 아래 공간 - 로그아웃, 탈퇴
                    SizedBox(height: 40),
                    Divider(),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: confirmLogout,
                        child: Text('로그아웃'),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: withdrawAccount,
                        child: Text(
                          '탈퇴하기',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: HomeNavigation(currentIndex: 2),
    );
  }
}
