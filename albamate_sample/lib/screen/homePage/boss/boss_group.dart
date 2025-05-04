import 'package:flutter/material.dart';
import '/component/home_navigation_boss.dart';
import 'create_group.dart';
import 'edit_group.dart';
import 'group_card.dart';

class BossHomegroup extends StatelessWidget {
  const BossHomegroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('그룹 관리')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: const [
              GroupCard(
                groupName: "예제 카페",
                groupDescription: "이것은 예제 그룹 설명입니다.",
                groupId: '',
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 30,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupPage(),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              label: const Text("CREATE"),
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeNavigation(currentIndex: 0),
    );
  }
}
