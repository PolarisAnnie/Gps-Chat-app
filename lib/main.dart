import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv import
import 'package:flutter_riverpod/flutter_riverpod.dart'; // riverpod import

import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/firebase_options.dart';

import 'package:gps_chat_app/ui/pages/main/main_navigation_page.dart';
import 'package:gps_chat_app/ui/pages/auth/register_page.dart';
import 'package:gps_chat_app/ui/pages/auth/signup_page.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_page.dart';
import 'package:gps_chat_app/ui/pages/location_settings/location_settings.dart';
import 'package:gps_chat_app/ui/pages/splash/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env"); // 환경변수 초기화 (.env 파일 필수)

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Chat App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
      routes: {
        '/splash': (context) => const SplashPage(),
        '/signup': (context) => SignupPage(),
        '/register': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return RegisterPage(nickname: args?['nickname'] as String? ?? '');
        },
        '/location': (context) => LocationSettings(
          user: ModalRoute.of(context)!.settings.arguments as User,
        ),
        '/main': (context) => const MainNavigationPage(), // 메인 네비게이션으로 변경
        '/chat': (context) => ChatPage(), // 개별 채팅방용
      },
    );
  }
}
