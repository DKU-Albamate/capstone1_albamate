import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../component/home_navigation_worker.dart';
import '../../homePage/boss/group_card.dart'; // 그룹 카드 위젯 import

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
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      final response = await http.get(
        Uri.parse('https://backend-vgbf.onrender.com/api/groups'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        setState(() {
          _groups = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        throw Exception('그룹 정보를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('직원 그룹 관리')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? const Center(child: Text('가입된 그룹이 없습니다.'))
              : ListView.builder(
                  itemCount: _groups.length,
                  itemBuilder: (context, index) {
                    final group = _groups[index];
                    return GroupCard(
                      groupId: group['id'].toString(),
                      groupName: group['name'] ?? '',
                      groupDescription: group['description'] ?? '',
                      onGroupUpdated: _loadGroups,
                    );
                  },
                ),
      bottomNavigationBar: const HomeNavigationWorker(currentIndex: 0),
    );
  }
}
