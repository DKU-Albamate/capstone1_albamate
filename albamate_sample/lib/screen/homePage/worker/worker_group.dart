import 'package:flutter/material.dart';
import '../../../component/home_navigation_worker.dart';

class WorkerGroup extends StatelessWidget {
  const WorkerGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('직원 그룹 관리')),
      body: const Center(child: Text('여기에 그룹 카드 리스트가 나옵니다.')),
      bottomNavigationBar: const HomeNavigationWorker(currentIndex: 0),
    );
  }
}
