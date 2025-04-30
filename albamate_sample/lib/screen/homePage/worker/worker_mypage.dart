import 'package:flutter/material.dart';
import '../../../component/home_navigation_worker.dart';

class WorkerMyPage extends StatelessWidget {
  const WorkerMyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('직원 마이페이지')),
      body: const Center(child: Text('직원 정보 및 설정 페이지')),
      bottomNavigationBar: const HomeNavigationWorker(currentIndex: 2), // ✅ 추가
    );
  }
}
