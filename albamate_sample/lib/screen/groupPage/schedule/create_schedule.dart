import 'package:flutter/material.dart';

class CreateSchedulePostPage extends StatefulWidget {
  const CreateSchedulePostPage({super.key});

  @override
  State<CreateSchedulePostPage> createState() => _CreateSchedulePostPageState();
}

class _CreateSchedulePostPageState extends State<CreateSchedulePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isFormValid
                        ? () {
                          final newSchedule = {
                            'title': _titleController.text,
                            'description': _descController.text,
                            'createdAt': DateTime.now().toIso8601String(),
                          };
                          Navigator.pop(context, newSchedule);
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
