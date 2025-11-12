import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/api.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CreateSchedulePostPage extends StatefulWidget {
  final String groupId;
  const CreateSchedulePostPage({super.key, required this.groupId});

  @override
  State<CreateSchedulePostPage> createState() => _CreateSchedulePostPageState();
}

class _CreateSchedulePostPageState extends State<CreateSchedulePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  bool get isFormValid =>
      _titleController.text.isNotEmpty && _descController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("스케줄 게시물 생성")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "스케줄 제목"),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "스케줄 설명"),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // 년도 선택 Dropdown
            Row(
              children: [
                const Text("년도 선택: "),
                DropdownButton<int>(
                  value: selectedYear,
                  items: List.generate(
                    10,
                    (index) => DropdownMenuItem(
                      value: DateTime.now().year + index,
                      child: Text("${DateTime.now().year + index}년"),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedYear = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 🔹 월 선택 Dropdown
            Row(
              children: [
                const Text("월 선택: "),
                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(
                    12,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text("${index + 1}월"),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedMonth = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormValid
                    ? () async {
                        final user = FirebaseAuth.instance.currentUser;
                        final idToken = await user?.getIdToken();
                        final response = await http.post(
                          Uri.parse('$BACKEND_SCHEDULE_BASE/api/schedules/create'),
                          headers: {
                            'Authorization': 'Bearer $idToken',
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode({
                            'groupId': widget.groupId,
                            'title': _titleController.text,
                            'description': _descController.text,
                            'year': selectedYear,
                            'month': selectedMonth,
                          }),
                        );

                        if (response.statusCode == 201) {
                          final responseData = jsonDecode(response.body)['data'];

                          Navigator.pop(context, {
                            'scheduleId': responseData['scheduleId'],
                            'title': _titleController.text,
                            'description': _descController.text,
                            'year': selectedYear,
                            'month': selectedMonth,
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('스케줄 생성 실패: ${response.body}')),
                          );
                        }
                      }
                    : null,
                child: const Text("게시물 생성 완료"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
