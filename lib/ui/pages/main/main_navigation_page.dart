import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/providers/viewmodels/main_navigation_viewmodel.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/ui/pages/chat_room_list/chat_room_list_page.dart';
import 'package:gps_chat_app/ui/pages/home/home_page.dart';
import 'package:gps_chat_app/ui/pages/profile/profile_page.dart';

class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(mainNavigationViewModelProvider);
    final navigationViewModel = ref.read(
      mainNavigationViewModelProvider.notifier,
    );

    final List<Widget> pages = [
      const HomePage(),
      ChatRoomListPage(),
      ProfilePage(),
    ];

    return Scaffold(
      // IndexedStack을 사용하면 탭 전환 시 페이지 상태가 유지된다고 하네용
      body: IndexedStack(index: navigationState.currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationState.currentIndex,
        onTap: navigationViewModel.changeTab, // 탭 변경 함수 호출
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
