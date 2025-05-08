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
                    groupId: groupId,
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
            PopupMenuItem(value: 'invite', child: Text('초대 코드 보기')), // ✅ 문구 변경
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
      final response = await http.get( // ✅ GET 요청으로 변경
        Uri.parse('https://backend-vgbf.onrender.com/api/groups/$groupId/invite-code'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer yourToken', // 필요시 추가
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final code = data['data']['inviteCode'];
        final expiresAt = data['data']['inviteCodeExpiresAt'];

        // ✅ 코드 자동 복사
        await Clipboard.setData(ClipboardData(text: code));

        // ✅ 복사 완료 메시지
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('초대 코드 확인'),
            content: Text('초대 코드가 자동 복사되었습니다.\n\n📎 $code\n🕒 유효 기간: $expiresAt'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('초대 코드 조회 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 코드를 불러오는 데 실패했습니다.')),
      );
    }
  }
}
