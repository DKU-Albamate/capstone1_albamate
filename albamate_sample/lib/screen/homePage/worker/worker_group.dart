import 'package:flutter/material.dart';
import 'package:albamate_sample/component/home_navigation_worker.dart';
import 'worker_card.dart';

class WorkerGroup extends StatelessWidget {
  const WorkerGroup({super.key});

  void _showInviteCodeDialog(BuildContext context) {
    final TextEditingController _codeController = TextEditingController();
    String _warningMessage = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.white,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 안내 문구
                        const Text(
                          '초대 코드를 입력하세요',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // 입력 필드
                        TextField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            hintText: '초대 코드',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 경고 메시지 출력
                        if (_warningMessage.isNotEmpty)
                          Text(
                            _warningMessage,
                            style: const TextStyle(color: Colors.red),
                          ),

                        const SizedBox(height: 16),

                        // 참여하기 버튼
                        ElevatedButton(
                          onPressed: () {
                            final code = _codeController.text.trim();
                            if (code.isEmpty) {
                              setState(() {
                                _warningMessage = '초대코드를 입력해주세요';
                              });
                              return;
                            }

                            // TODO: 여기에 초대 코드 검증 및 그룹 참여 API 호출 로직
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('코드 "$code" 제출됨 (예시 메시지)')),
                            );
                          },
                          child: const Text('참여하기'),
                        ),
                      ],
                    ),
                  ),

                  // 닫기 아이콘
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('그룹 참여')),
      body: Stack(
        children: [
          // 그룹 카드 리스트
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: const [
              GroupCard(
                groupName: "예제 카페",
                groupDescription: "참여한 그룹 설명입니다.",
                groupId: 'dummy-group-id',
              ),
            ],
          ),

          // 그룹 참여 버튼
          Positioned(
            right: 16,
            bottom: 30,
            child: FloatingActionButton.extended(
              onPressed: () => _showInviteCodeDialog(context),
              backgroundColor: Colors.blue,
              label: const Text("그룹 참여", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const HomeNavigationWorker(currentIndex: 0),
    );
  }
}
