import 'package:flutter/material.dart';

class CreateSchedulePostPage extends StatefulWidget {
  const CreateSchedulePostPage({super.key});

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
                onPressed:
                    isFormValid
                        ? () {
                          final newSchedule = {
                            'title': _titleController.text,
                            'description': _descController.text,
                            'year': selectedYear,
                            'month': selectedMonth,
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
