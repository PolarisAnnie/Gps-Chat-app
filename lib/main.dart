import 'package:flutter/material.dart';
import 'package:gps_chat_app/ui/pages/auth/login_page.dart';
import 'package:gps_chat_app/ui/pages/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}
