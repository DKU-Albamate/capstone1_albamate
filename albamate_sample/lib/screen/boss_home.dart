// BossPage.dart
import 'package:flutter/material.dart';

class BossPage extends StatelessWidget {
  const BossPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사장님 페이지')),
      body: Center(child: const Text('사장님 페이지에 오신 것을 환영합니다!')),
    );
  }
}
