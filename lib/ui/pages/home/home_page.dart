import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/providers/viewmodels/nearby_users_provider.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/ui/pages/chat_room_list/chat_room_list_view_model.dart';
import 'package:gps_chat_app/ui/pages/home/widgets/cafe_suggestion.dart';
import 'package:gps_chat_app/ui/pages/home/widgets/current_location_bar.dart';
import 'package:gps_chat_app/ui/pages/home/widgets/member_list.dart';
import 'package:gps_chat_app/ui/pages/welcome/location_settings/location_settings.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser != null && !_initialized) {
        _initialized = true;
        final vm = ref.read(chatRoomListViewModelProvider.notifier);
        vm.setUserContext(currentUser.userId, currentUser.address ?? '');
        vm.startChatRoomsStream();
        print('🟦 홈에서 채팅방 스트림 시작');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser != null) {
        final vm = ref.read(chatRoomListViewModelProvider.notifier);
        vm.setUserContext(currentUser.userId, currentUser.address ?? '');
        vm.startChatRoomsStream();
        print('🟦 홈에서 채팅방 스트림 재시작');

        // 앱이 다시 포커스될 때 사용자 정보와 주변 사용자 새로고침
        ref.invalidate(currentUserProvider);
        ref.invalidate(nearbyUsersProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final nearbyUsersAsync = ref.watch(nearbyUsersProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              currentUserAsync.when(
                data: (user) {
                  String locationText;
                  if (user == null) {
                    locationText = '로그인이 필요합니다';
                  } else if (user.address == null || user.address!.isEmpty) {
                    locationText = '위치 설정이 필요합니다';
                  } else {
                    locationText = user.address!;
                  }

                  return CurrentLocationBar(
                    location: locationText,
                    // onPinTap에 페이지 이동 로직 구현
                    onPinTap: () {
                      // 현재 유저 정보가 있을 때만 페이지 이동
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationSettings(
                              user: user,
                              // 이 페이지가 홈에서 왔다는 것을 알리는 플래그 전달
                              isFromHomePage: true,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },

                loading: () =>
                    const CurrentLocationBar(location: '위치 정보 로딩중...'),
                error: (err, stack) =>
                    const CurrentLocationBar(location: '위치 정보를 가져올 수 없습니다.'),
              ),
              const SizedBox(height: 20),
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
              nearbyUsersAsync.when(
                data: (users) => MemberList(members: users),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Center(child: Text('사용자 목록을 불러오는 데 실패했습니다.')),
                ),
              ),
              const SizedBox(height: 30),
              CafeSuggestion(),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
