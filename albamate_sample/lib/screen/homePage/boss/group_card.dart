import 'package:flutter/material.dart';
import 'edit_group.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
              // 그룹 수정 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditGroupPage(
                        groupName: groupName,
                        groupDescription: groupDescription,
                      ),
                ),
              );
            } else if (value == 'delete') {
              // 그룹 삭제 기능 호출
              // 성공 시 UI에서 해당 카드 제거
            } else if (value == 'invite') {
              await _showInviteCodeDialog(context);
              // todo: POST /api/groups/{groupID}/invite-code 호출
              // 그룹 생성 후 그룹 초대 코드 재발급 원할 시
            }
          },
          itemBuilder:
              (BuildContext context) => const [
                PopupMenuItem(value: 'edit', child: Text('수정')),
                PopupMenuItem(value: 'delete', child: Text('삭제')),
                PopupMenuItem(value: 'invite', child: Text('초대 코드 재발급')),
              ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupHomePage(groupId: groupId),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showInviteCodeDialog(BuildContext context) async {
    try {
      final response = await http.post(
        // 예시
        Uri.parse('https://your-api-url.com/api/groups/$groupId/invite-code'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer yourToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final code = data['newInviteCode'];
        final expiresAt = data['expiresAt'];

        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('초대 코드 재발급'),
                content: Text('코드: $code\n유효 기간: $expiresAt'),
                actions: [
                  TextButton(
                    onPressed: () {
                      // 클립보드 복사 기능 예정
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('초대 코드 재발급에 실패했습니다.')));
    }
  }
}
