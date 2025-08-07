import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gps_chat_app/firebase_options.dart';
import 'package:gps_chat_app/ui/pages/splash/splash_page.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashPage());
  }
}
