import 'package:flutter/material.dart';

class EditGroupPage extends StatefulWidget {
  final String groupName;
  final String groupDescription;

  const EditGroupPage({
    super.key,
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

  bool get isFormValid =>
      _nameController.text.isNotEmpty && _descController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.groupName);
    _descController = TextEditingController(text: widget.groupDescription);
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
                          // 그룹 수정 API 호출
                          // todo: PUT /api/groups/{groupID} 호출
                          // 수정 완료 시 그룹 관리 페이지에서 보이는 카드 내용이 수정되어야함
                        }
                        : null,
                child: const Text("수정 완료"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
