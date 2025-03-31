// WorkerPage.dart
import 'package:flutter/material.dart';

class WorkerPage extends StatelessWidget {
  const WorkerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알바생 페이지')),
      body: Center(child: const Text('알바생 페이지에 오신 것을 환영합니다!')),
    );
  }
}
