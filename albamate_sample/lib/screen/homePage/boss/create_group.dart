import 'package:flutter/material.dart';

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
                  onChanged:
                      (value) => setState(() => useAutoSchedule = value!),
                ),
                const Text("사용함"),
                Radio<bool>(
                  value: false,
                  groupValue: useAutoSchedule,
                  onChanged:
                      (value) => setState(() => useAutoSchedule = value!),
                ),
                const Text("사용 안함"),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isFormValid
                        ? () {
                          // 그룹 생성 API 호출 및 초대 코드 발급 요청
                          // todo: POST /api/groups 호출
                          // 초대 코드 발급 구현 시 API를 활용해 초대 코드 클립보드 복사 및 초대 코드 공유 기능 구현 예정
                        }
                        : null,
                child: const Text("그룹 생성 및 초대 코드 발급"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
