import 'package:flutter/material.dart';
import 'package:albamate_sample/component/home_navigation_worker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'worker_card.dart';

class WorkerGroup extends StatefulWidget {
  const WorkerGroup({super.key});

  @override
  State<WorkerGroup> createState() => _WorkerGroupState();
}

class _WorkerGroupState extends State<WorkerGroup> {
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse('https://backend-vgbf.onrender.com/api/groups'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          setState(() {
            _groups = List<Map<String, dynamic>>.from(jsonData['data']);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('그룹 불러오기 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _joinGroup(String inviteCode) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final idToken = await user.getIdToken();
      final response = await http.post(
        Uri.parse('https://backend-vgbf.onrender.com/api/groups/join'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inviteCode': inviteCode, 'userUid': user.uid}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('그룹 참여가 완료되었습니다.')));
          _fetchGroups(); // 그룹 목록 새로고침
          return true;
        }
      }
      throw Exception('그룹 참여에 실패했습니다.');
    } catch (e) {
      rethrow;
    }
  }

  void _showInviteCodeDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    String warningMessage = '';
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '초대 코드를 입력하세요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: codeController,
                          decoration: const InputDecoration(
                            hintText: '초대 코드',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (warningMessage.isNotEmpty)
                          Text(
                            warningMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              isSubmitting
                                  ? null
                                  : () async {
                                    final code = codeController.text.trim();
                                    if (code.isEmpty) {
                                      setState(() {
                                        warningMessage = '초대코드를 입력해주세요';
                                      });
                                      return;
                                    }

                                    setState(() {
                                      isSubmitting = true;
                                      warningMessage = '';
                                    });

                                    try {
                                      await _joinGroup(code);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      setState(() {
                                        warningMessage = e.toString();
                                        isSubmitting = false;
                                      });
                                    }
                                  },
                          child:
                              isSubmitting
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('참여하기'),
                        ),
                      ],
                    ),
                  ),
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _groups.isEmpty
              ? const Center(child: Text('참여한 그룹이 없습니다.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _groups.length,
                itemBuilder: (context, index) {
                  final group = _groups[index];
                  return GroupCard(
                    groupId: group['id'],
                    groupName: group['name'],
                    groupDescription: group['description'] ?? '',
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInviteCodeDialog(context),
        backgroundColor: Colors.blue,
        label: const Text("그룹 참여", style: TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: const HomeNavigationWorker(currentIndex: 0),
    );
  }
}
