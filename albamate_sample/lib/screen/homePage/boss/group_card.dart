import 'package:albamate_sample/component/groupHome_navigation.dart';
import 'package:flutter/material.dart';
import 'edit_group.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // ✅ 클립보드 복사용
import '../../groupPage/groupHome.dart';

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
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditGroupPage(
                    groupName: groupName,
                    groupDescription: groupDescription,
                  ),
                ),
              );
            } else if (value == 'delete') {
              // TODO: 그룹 삭제 구현 예정
            } else if (value == 'invite') {
              await _showInviteCodeDialog(context);
            }
          },
          itemBuilder: (BuildContext context) => const [
            PopupMenuItem(value: 'edit', child: Text('수정')),
            PopupMenuItem(value: 'delete', child: Text('삭제')),
            PopupMenuItem(value: 'invite', child: Text('초대 코드 재발급')),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GroupNav(groupId: groupId)),
          );
        },
      ),
    );
  }

  Future<void> _showInviteCodeDialog(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('https://backend-vgbf.onrender.com/api/groups/$groupId/invite-code'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer yourToken', // 필요한 경우 추가
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final code = data['data']['inviteCode'];
        final expiresAt = data['data']['inviteCodeExpiresAt'];

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('초대 코드 재발급'),
            content: Text('코드: $code\n유효 기간: $expiresAt'),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('초대 코드가 복사되었습니다.')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('복사하기'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('재발급 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 코드 재발급에 실패했습니다.')),
      );
    }
  }
}
