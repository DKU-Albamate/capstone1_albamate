import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // 클립보드 복사용

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool useAutoSchedule = false;
  bool isLoading = false;

  bool get isFormValid =>
      _nameController.text.isNotEmpty && _descController.text.isNotEmpty;

  Future<void> _submitGroup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);
    final idToken = await user.getIdToken();

    final response = await http.post(
      Uri.parse('https://backend-vgbf.onrender.com/api/groups'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'useAutoAssignment': useAutoSchedule,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        final groupId = responseData['data']['groupId'];
      if (groupId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('그룹 ID를 받지 못했습니다.')),
        );
        return;
      }
      _showInviteCodeDialog(groupId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 응답이 올바르지 않습니다.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 생성에 실패했습니다.')),
      );
    }
  }

  Future<void> _showInviteCodeDialog(String groupId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final idToken = await user.getIdToken();

    final response = await http.post(
      Uri.parse('https://backend-vgbf.onrender.com/api/groups/$groupId/invite-code'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      final code = data['inviteCode'];
      final expiresAt = data['inviteCodeExpiresAt'];

      // ✅ 클립보드 자동 복사
      await Clipboard.setData(ClipboardData(text: code));

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('초대 코드 복사 완료'),
          content: Text('초대 코드가 자동 복사되었습니다.\n\n📎 $code\n🕒 유효 기간: $expiresAt'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                  ..pop()
                  ..pop(true); // 그룹 생성 성공 후 true 반환
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context, true); // 실패해도 그룹 생성은 성공 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('그룹 생성 및 초대 코드 발급')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '그룹 이름'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: '그룹 설명'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('자동 스케줄 사용 여부'),
                const SizedBox(width: 12),
                Radio<bool>(
                  value: true,
                  groupValue: useAutoSchedule,
                  onChanged: (value) =>
                      setState(() => useAutoSchedule = value!),
                ),
                const Text('사용함'),
                Radio<bool>(
                  value: false,
                  groupValue: useAutoSchedule,
                  onChanged: (value) =>
                      setState(() => useAutoSchedule = value!),
                ),
                const Text('사용 안함'),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormValid && !isLoading ? _submitGroup : null,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('그룹 생성 및 초대 코드 발급'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
