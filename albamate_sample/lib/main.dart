import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ 추가
import 'firebase_options.dart';
import 'screen/onboarding.dart';
import 'screen/invite/invite_handler.dart'; // ❗️이 파일을 따로 만들어야 함

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 로케일 데이터 초기화 (ko_KR용 DateFormat 사용 시 필요)
  await initializeDateFormatting('ko_KR', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 딥링크로 앱이 시작되었는지 확인
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

    // 초대 코드 딥링크로 앱이 열렸을 경우
    if (deepLink != null && deepLink.queryParameters.containsKey('code')) {
      final String inviteCode = deepLink.queryParameters['code']!;
      startPage = InviteHandlerPage(inviteCode: inviteCode);
    }

    return MaterialApp(
      title: 'AlbaMate',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: startPage,
    );
  }
}
