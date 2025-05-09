import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'firebase_options.dart';
import 'screen/onboarding.dart';
import 'screen/invite/invite_handler.dart'; // ❗️이 파일을 따로 만들어야 함

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 최초 실행 시 딥링크 데이터 확인
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();

  runApp(MyApp(initialLink: initialLink));
}

class MyApp extends StatelessWidget {
  final PendingDynamicLinkData? initialLink;
  const MyApp({super.key, this.initialLink});

  @override
  Widget build(BuildContext context) {
    final Uri? deepLink = initialLink?.link;

    Widget startPage = const OnboardingScreen(); // 기본 시작 화면

    // 딥링크에 초대 코드(code)가 포함되어 있으면 자동 가입 처리 페이지로 이동
    if (deepLink != null && deepLink.queryParameters.containsKey('code')) {
      final String inviteCode = deepLink.queryParameters['code']!;
      startPage = InviteHandlerPage(inviteCode: inviteCode);
    }

    return MaterialApp(
      title: 'AlbaMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: startPage,
    );
  }
}
