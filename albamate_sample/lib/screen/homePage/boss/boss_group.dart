import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'group_card.dart';
import '../../../component/home_navigation_boss.dart';
import 'create_group.dart';

class BossGroup extends StatefulWidget {
  const BossGroup({super.key});

  @override
  State<BossGroup> createState() => _BossGroupState();
}

class _BossGroupState extends State<BossGroup> {
  List<GroupModel> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  // 그룹 목록 불러오기
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
        final List<dynamic> data = jsonData['data'];

        setState(() {
          _groups = data.map((item) => GroupModel.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        print('그룹 불러오기 실패: ${response.body}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('예외 발생: $e');
      setState(() => _isLoading = false);
    }
  }

  // 그룹 생성 페이지로 이동
  Future<void> _goToCreateGroup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateGroupPage()),
    );

    if (result == true) {
      _fetchGroups(); // 새 그룹 반영
    }
  }

  // 디버그용: ID 토큰 출력 함수 (사용 안 함, 버튼 제거됨)
  Future<void> _printIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idToken = await user.getIdToken(true);
      print('[DEBUG] idToken: $idToken');
    } else {
      print('로그인된 사용자가 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 관리'),
        automaticallyImplyLeading: false,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _groups.isEmpty
              ? const Center(child: Text("그룹이 없습니다."))
              : ListView.builder(
                itemCount: _groups.length,
                itemBuilder: (context, index) {
                  final group = _groups[index];
                  return GroupCard(
                    groupId: group.id,
                    groupName: group.name,
                    groupDescription: group.description,
                    onGroupUpdated: _fetchGroups,
                  );
                },
              ),
      floatingActionButton: ElevatedButton(
        onPressed: _goToCreateGroup,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006FFD), // 파란색 배경
          foregroundColor: Colors.white, // 흰색 글씨
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'CREATE',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: const HomeNavigationBoss(currentIndex: 0),
    );
  }
}

// 그룹 모델 클래스
class GroupModel {
  final String id;
  final String name;
  final String description;

  GroupModel({required this.id, required this.name, required this.description});

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'] ?? '',
    );
  }
}
