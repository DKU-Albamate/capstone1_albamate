import 'package:albamate_sample/screen/homePage/worker/worker_homecalendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:albamate_sample/screen/homePage/boss/boss_homeCalendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroupHomePage extends StatefulWidget {
  final String groupId;

  const GroupHomePage({super.key, required this.groupId});

  @override
  State<GroupHomePage> createState() => _GroupHomePageState();
}

class _GroupHomePageState extends State<GroupHomePage> {
  late String formattedDate;
  List<Map<String, dynamic>> tasks = [];
  TextEditingController taskController = TextEditingController();
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat(
      'yyyy년 MM월 dd일 EEEE',
      'ko_KR',
    ).format(DateTime.now());
    fetchTasks();
  }

  // 할 일 목록 조회
  Future<void> fetchTasks() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse('https://backend-vgbf.onrender.com/api/tasks/group/${widget.groupId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          tasks = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        setState(() {
          error = '할 일을 불러오는데 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        error = '서버 연결에 실패했습니다.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 할 일 추가
  Future<void> addTask() async {
    if (taskController.text.isEmpty) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('https://backend-vgbf.onrender.com/api/tasks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'groupId': widget.groupId,
          'content': taskController.text,
        }),
      );

      if (response.statusCode == 201) {
        taskController.clear();
        await fetchTasks();
      } else {
        setState(() {
          error = '할 일 추가에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        error = '서버 연결에 실패했습니다.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 할 일 삭제
  Future<void> removeTask(String taskId) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.delete(
        Uri.parse('https://backend-vgbf.onrender.com/api/tasks/$taskId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await fetchTasks();
      } else {
        setState(() {
          error = '할 일 삭제에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        error = '서버 연결에 실패했습니다.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 할 일 완료 상태 토글
  Future<void> toggleTaskCompletion(String taskId) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.patch(
        Uri.parse('https://backend-vgbf.onrender.com/api/tasks/$taskId/toggle'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await fetchTasks();
      } else {
        setState(() {
          error = '할 일 상태 변경에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        error = '서버 연결에 실패했습니다.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 홈'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;

              if (uid != null) {
                final userDoc =
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .get();
                final role = userDoc['role'];

                if (role == '사장님') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BossHomecalendar()),
                  );
                } else if (role == '알바생') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkerHomecalendar(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('알 수 없는 사용자 역할입니다.')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그인 정보가 없습니다.')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '오늘 근무자',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(children: List.generate(3, (index) => const EmployeeCard())),
            const SizedBox(height: 24),
            const Text(
              '오늘 할 일',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      hintText: "할 일을 입력하세요",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isLoading ? null : addTask,
                  child: const Text("추가"),
                ),
              ],
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 8),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(
                      task['content'],
                      style: TextStyle(
                        decoration: task['is_completed'] == true
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    leading: Checkbox(
                      value: task['is_completed'] == true,
                      onChanged: (value) => toggleTaskCompletion(task['id']),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => removeTask(task['id']),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// 각 직원 카드 위젯
class EmployeeCard extends StatelessWidget {
  const EmployeeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text("000 직원"),
        subtitle: const Text("8:00 ~ 15:00"),
      ),
    );
  }
}
