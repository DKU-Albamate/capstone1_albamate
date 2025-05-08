import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class EditGroupPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupDescription;

  const EditGroupPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupDescription,
  });

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  bool useAutoSchedule = false;
  bool isLoading = false;

  bool get isFormValid =>
      _nameController.text.isNotEmpty && _descController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.groupName);
    _descController = TextEditingController(text: widget.groupDescription);
  }

  Future<void> _submitUpdate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);
    final idToken = await user.getIdToken();

    final response = await http.put(
      Uri.parse('https://backend-vgbf.onrender.com/api/groups/${widget.groupId}'),
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

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 정보가 수정되었습니다.')),
      );
      Navigator.pop(context, true); // 이전 페이지에 성공 알림
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 수정에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("그룹 수정")),
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
                  onChanged: (value) => setState(() => useAutoSchedule = value!),
                ),
                const Text("사용함"),
                Radio<bool>(
                  value: false,
                  groupValue: useAutoSchedule,
                  onChanged: (value) => setState(() => useAutoSchedule = value!),
                ),
                const Text("사용 안함"),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormValid && !isLoading ? _submitUpdate : null,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("수정 완료"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
