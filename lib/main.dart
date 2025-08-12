import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv import
import 'package:flutter_riverpod/flutter_riverpod.dart'; // riverpod import

import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/firebase_options.dart';
import 'package:gps_chat_app/ui/pages/chat_room_list/chat_room_list_page.dart';
import 'package:gps_chat_app/ui/pages/home/home_page.dart';

import 'package:gps_chat_app/ui/pages/main/main_navigation_page.dart';
import 'package:gps_chat_app/ui/pages/welcome/auth/register_page.dart';
import 'package:gps_chat_app/ui/pages/welcome/auth/signup_page.dart';
import 'package:gps_chat_app/ui/pages/welcome/location_settings/location_settings.dart';
import 'package:gps_chat_app/ui/pages/welcome/splash/splash_page.dart';

//
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
        '/main': (context) => MainNavigationPage(), // 메인 네비게이션으로 변경
        '/chat-list': (context) => ChatRoomListPage(), // 채팅방 리스트 페이지로 이동
      },
    );
  }
}
