import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // 추가
import 'firebase_options.dart';
import 'screen/onboarding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://unkliehgimaceqjjrmmx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVua2xpZWhnaW1hY2VxampybW14Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYzNTE0MDAsImV4cCI6MjA2MTkyNzQwMH0.P0kUwkZbTXc8PjBMo15FKb2vKVj6b83vFchO1icV2fE',
  );

  // 로케일 데이터 초기화 (ko_KR용 DateFormat 사용 시 필요)
  await initializeDateFormatting('ko_KR', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlbaMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Pretendard',
        // 후보 폰트
        // fontFamily: 'NotoSansKR',
        // fontFamily: 'GmarketSans',
      ),
      // ✅ [필수 수정] Localizations Delegate 설정 추가
      // ===============================================================
      localizationsDelegates: const [
        // 1. 머티리얼 위젯 (DatePicker, TimePicker) 현지화
        GlobalMaterialLocalizations.delegate,
        // 2. 위젯 기본 로케일 처리 (텍스트 방향 등)
        GlobalWidgetsLocalizations.delegate,
        // 3. iOS 스타일 위젯 현지화 (선택 사항이지만 포함 권장)
        GlobalCupertinoLocalizations.delegate,
      ],

      // ✅ [필수 수정] 지원 로케일 목록 설정
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어 지원
        Locale('en', 'US'), // 영어 지원 (기본)
      ],

      // ✅ 기본 로케일을 한국어로 지정 (선택 사항이지만 일관성을 위해 권장)
      locale: const Locale('ko', 'KR'),
      // ===============================================================
      home: const OnboardingScreen(),
    );
  }
}
