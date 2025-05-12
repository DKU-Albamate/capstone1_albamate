import 'package:albamate_sample/screen/homePage/worker/worker_homecalendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:albamate_sample/screen/homePage/boss/boss_homeCalendar.dart';

class GroupHomePage extends StatefulWidget {
  final String groupId;

  const GroupHomePage({super.key, required this.groupId});

  @override
  State<GroupHomePage> createState() => _GroupHomePageState();
}

class _GroupHomePageState extends State<GroupHomePage> {
  late String formattedDate;
  List<String> tasks = [];
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat(
      'yyyy년 MM월 dd일 EEEE',
      'ko_KR',
    ).format(DateTime.now());
  }

  // 오늘 할 일 추가
  void addTask() {
    if (taskController.text.isNotEmpty) {
      setState(() {
        tasks.add(taskController.text);
        taskController.clear();
      });
    }
  }

  // 할 일 삭제
  void removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 홈'),
        centerTitle: true,
        actions: [
          //상단 왼쪽 X 버튼
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('로그인 정보가 없습니다.')));
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
                ElevatedButton(onPressed: addTask, child: const Text("추가")),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tasks[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => removeTask(index),
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
