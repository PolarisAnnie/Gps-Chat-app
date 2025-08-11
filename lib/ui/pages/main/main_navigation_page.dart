import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/viewmodels/main_navigation_viewmodel.dart';
import '../home/home_page.dart';
import '../chat/chat_page.dart';
import '../profile/profile_page.dart';

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
      ChatPage(), // ChatPage는 임시로 기본 생성자 사용
      ProfilePage(), // ProfilePage는 const가 아님
    ];

    return Scaffold(
      body: pages[navigationState.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationState.currentIndex,
        onTap: navigationViewModel.changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3266FF),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
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
