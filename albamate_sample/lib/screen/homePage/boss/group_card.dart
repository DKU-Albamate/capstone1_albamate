import 'package:albamate_sample/component/groupHome_navigation.dart';
import 'package:flutter/material.dart';
import 'edit_group.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String groupDescription;
  final VoidCallback onGroupUpdated; // 수정 후 새로고침용 콜백

  const GroupCard({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupDescription,
    required this.onGroupUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ), // 좌우 여백 추가로 가로 길이 줄이기
      child: Card(
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
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditGroupPage(
                          groupId: groupId,
                          groupName: groupName,
                          groupDescription: groupDescription,
                        ),
                  ),
                );
                if (result == true) {
                  onGroupUpdated(); // 수정 성공 시 새로고침
                }
              } else if (value == 'delete') {
                await _deleteGroup(context);
              } else if (value == 'invite') {
                await _showInviteCodeDialog(context);
              }
            },
            itemBuilder:
                (BuildContext context) => const [
                  PopupMenuItem(value: 'edit', child: Text('수정')),
                  PopupMenuItem(value: 'delete', child: Text('삭제')),
                  PopupMenuItem(value: 'invite', child: Text('초대 코드 보기')),
                ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // 사장님뷰로만 확인 가능
                builder:
                    (context) => GroupNav(groupId: groupId, userRole: '사장님'),
              ),
            );
          },
        ),
      ),
    );
  }

  // 초대 코드 다이얼로그 표시
  Future<void> _showInviteCodeDialog(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse(
          'https://backend-vgbf.onrender.com/api/groups/$groupId/invite-code',
        ),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final code = data['data']['inviteCode'];
          final expiresAt = data['data']['inviteCodeExpiresAt'];

          await Clipboard.setData(ClipboardData(text: code));

          if (!context.mounted) return;
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('초대 코드 확인'),
                  content: Text(
                    '초대 코드가 자동 복사되었습니다.\n\n📎 $code\n🕒 유효 기간: $expiresAt',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('닫기'),
                    ),
                  ],
                ),
          );
        } else {
          throw Exception('초대 코드 데이터가 올바르지 않습니다.');
        }
      } else {
        throw Exception('초대 코드 조회 실패');
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('초대 코드를 불러오는 데 실패했습니다.')));
    }
  }

  // 그룹 삭제 처리
  Future<void> _deleteGroup(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('정말 삭제할까요?'),
            content: const Text('이 그룹을 삭제하면 복구할 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('삭제'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final idToken = await user.getIdToken();
      final response = await http.delete(
        Uri.parse('https://backend-vgbf.onrender.com/api/groups/$groupId'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('그룹이 삭제되었습니다.')));
        onGroupUpdated(); // ✅ 삭제 후 새로고침
      } else {
        throw Exception('그룹 삭제 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('그룹 삭제에 실패했습니다.')));
    }
  }
}
