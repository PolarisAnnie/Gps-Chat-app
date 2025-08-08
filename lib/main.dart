import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gps_chat_app/firebase_options.dart';
import 'package:gps_chat_app/ui/pages/home/home_page.dart';
import 'package:gps_chat_app/ui/pages/home/member_detail.dart';
import 'package:gps_chat_app/ui/pages/auth/register_page.dart';
import 'package:gps_chat_app/ui/pages/auth/signup_page.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_page.dart';
import 'package:gps_chat_app/ui/pages/home/home.dart';
import 'package:gps_chat_app/ui/pages/home/home_page.dart';
import 'package:gps_chat_app/ui/pages/location_settings/location_settings.dart';
import 'package:gps_chat_app/ui/pages/profile/profile_page.dart';
import 'package:gps_chat_app/ui/pages/splash/splash_page.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // debugPaintSizeEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MemberDetailPage());
    return MaterialApp(
      title: 'GPS Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'paperlogy',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: SignupPage(),
      routes: {
        '/splash': (context) => const SplashPage(),
        '/signup': (context) => SignupPage(),
        '/register': (context) => RegisterPage(
          nickname: ModalRoute.of(context)?.settings.arguments as String? ?? '',
        ),
        '/location': (context) => LocationSettings(
          userData:
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
        ),
        '/profile': (context) => ProfilePage(),
        '/home': (context) => Home(),
        '/chat': (context) => ChatPage(),
      },
    );
  }
}
