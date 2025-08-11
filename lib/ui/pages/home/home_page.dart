import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/providers/viewmodels/nearby_users_provider.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/ui/pages/home/widgets/cafe_suggestion.dart';
import 'package:gps_chat_app/ui/pages/home/widgets/current_location_bar.dart';
import 'package:gps_chat_app/ui/pages/home/widgets/member_list.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 유저 정보와 주변 유저 목록을 watch
    final currentUserAsync = ref.watch(currentUserProvider);
    final nearbyUsersAsync = ref.watch(nearbyUsersProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 헤더 부분 (현재 유저의 위치 표시)
              currentUserAsync.when(
                data: (user) => CurrentLocationBar(
                  location: user?.address ?? '위치 정보를 불러오는 중...',
                ),
                loading: () =>
                    const CurrentLocationBar(location: '위치 정보 로딩중...'),
                error: (err, stack) =>
                    const CurrentLocationBar(location: '위치 정보를 가져올 수 없습니다.'),
              ),
              const SizedBox(height: 20),

              // 지금 바로 연결 가능한, 텍스트
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                      TextSpan(text: ' 가능한,'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // 연결 가능한 친구 리스트
              nearbyUsersAsync.when(
                data: (users) =>
                    MemberList(members: users), // MemberList에 유저 목록 전달
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Center(child: Text('사용자 목록을 불러오는 데 실패했습니다.')),
                ),
              ),
              const SizedBox(height: 30),
              // 코딩하기 좋은 카페 추천
              CafeSuggestion(),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
