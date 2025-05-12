import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../homePage/worker/worker_group.dart'; // 그룹 홈 예시 화면

class InviteHandlerPage extends StatefulWidget {
  final String inviteCode;
  const InviteHandlerPage({super.key, required this.inviteCode});

  @override
  State<InviteHandlerPage> createState() => _InviteHandlerPageState();
}

class _InviteHandlerPageState extends State<InviteHandlerPage> {
  String? message;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _handleInvite();
  }

  Future<void> _handleInvite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        message = '로그인이 필요합니다.';
        isLoading = false;
      });
      return;
    }

    try {
      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse('https://backend-vgbf.onrender.com/api/groups/join'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'inviteCode': widget.inviteCode,
          'userUid': user.uid,
        }),
      );

      if (response.statusCode == 200) {
        // 성공적으로 그룹에 가입됨
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => WorkerGroup()),
        );
      } else {
        setState(() {
          message = '초대 코드가 유효하지 않거나 만료되었습니다.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = '오류 발생: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 12),
                  Text(message ?? '알 수 없는 오류'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('돌아가기'),
                  )
                ],
              ),
      ),
    );
  }
}
