import 'package:flutter/material.dart';
import 'package:albamate_sample/component/groupHome_navigation.dart';

class GroupCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String groupDescription;

  const GroupCard({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          groupName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(groupDescription),
        onTap: () {
          // 그룹 홈 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupNav(groupId: groupId, userRole: ''),
            ),
          );
        },
      ),
    );
  }
}
