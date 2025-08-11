import 'package:flutter/material.dart';
import 'package:gps_chat_app/ui/pages/home/widgets/cafe_suggestion.dart';
import 'package:gps_chat_app/ui/pages/home/widgets/current_location_bar.dart';
import 'package:gps_chat_app/ui/pages/home/widgets/member_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Column + SingleChildScrollView로 변경
          child: Column(
            children: [
              // 헤더 부분
              CurrentLocationBar(),
              const SizedBox(height: 10),

              // 지금 바로 연결 가능한, 텍스트
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Paperlogy',
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(text: '지금 '),
                      TextSpan(
                        text: '바로 연결',
                        style: TextStyle(color: Color(0xFF3266FF)),
                      ),
                      TextSpan(text: ' 가능한,'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // 연결 가능한 친구 리스트
              MemberList(),
              const SizedBox(height: 25),
              // 코딩하기 좋은 카페 추천
              CafeSuggestion(),
            ],
          ),
        ),
      ),
    );
  }
}
