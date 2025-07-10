import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // 추가
import 'firebase_options.dart';
import 'screen/onboarding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      home: const OnboardingScreen(),
    );
  }
}
