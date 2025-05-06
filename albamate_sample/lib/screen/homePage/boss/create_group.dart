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

  bool get isFormValid =>
      _nameController.text.isNotEmpty && _descController.text.isNotEmpty;

  Future<void> _createGroup() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인이 필요합니다.")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('https://backend-vgbf.onrender.com/api/groups'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'useAutoAssignment': useAutoSchedule,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      final code = data['inviteCode'];
      final expiresAt = data['inviteCodeExpiresAt'];

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('초대 코드 발급 완료'),
          content: Text('코드: $code\n유효 기간: $expiresAt'),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('초대 코드가 복사되었습니다.')),
                );
              },
              child: const Text('복사하기'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("그룹 생성에 실패했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("그룹 생성")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "그룹 이름"),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "그룹 설명"),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("자동 스케줄 사용 여부"),
                const SizedBox(width: 12),
                Radio<bool>(
                  value: true,
                  groupValue: useAutoSchedule,
                  onChanged: (value) =>
                      setState(() => useAutoSchedule = value!),
                ),
                const Text("사용함"),
                Radio<bool>(
                  value: false,
                  groupValue: useAutoSchedule,
                  onChanged: (value) =>
                      setState(() => useAutoSchedule = value!),
                ),
                const Text("사용 안함"),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormValid ? _createGroup : null,
                child: const Text("그룹 생성 및 초대 코드 발급"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
