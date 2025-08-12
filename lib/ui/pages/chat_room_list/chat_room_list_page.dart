import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_page.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_view_model.dart';
import 'package:gps_chat_app/ui/pages/chat_room_list/chat_room_list_view_model.dart';
import 'package:gps_chat_app/ui/pages/chat_room_list/widgets/chat_room_item.dart';

class ChatRoomListPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ChatRoomListPage> createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends ConsumerState<ChatRoomListPage>
    with WidgetsBindingObserver {
  bool _initialized = false;

  String _getOtherUserId(ChatRoom chatRoom, User currentUser) {
    return currentUser.userId == chatRoom.currentUserId
        ? chatRoom.otherUserId
        : chatRoom.currentUserId;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 앱 복귀 - 채팅방 스트림 재시작 시도');
      ref.read(chatRoomListViewModelProvider.notifier).startChatRoomsStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomListViewModelProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff3266FF),
          title: Text('채팅방 로딩 중...', style: TextStyle(color: Colors.white)),
        ),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('사용자 정보 로딩 실패: $error'))),
      data: (user) {
        if (user != null && !_initialized) {
          _initialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final vm = ref.read(chatRoomListViewModelProvider.notifier);
            vm.setUserContext(user.userId, user.address ?? '');
            vm.startChatRoomsStream(); // 1번만 실행
          });
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xff3266FF),
            title: Text(
              '열린 채팅방 ${state.chatRooms.length}개',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 24),
              itemCount: state.chatRooms.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final chatRoom = state.chatRooms[index];
                          final correctOtherUserId = _getOtherUserId(
                            chatRoom,
                            user!,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ChatPage(
                                  roomId: chatRoom.roomId,
                                  otherUserId: correctOtherUserId,
                                );
                              },
                            ),
                          );
                        },
                        child: ChatRoomItem(chatRoom: state.chatRooms[index]),
                      ),
                      SizedBox(height: 12),
                      if (index < state.chatRooms.length - 1)
                        Container(
                          height: 0.3,
                          width: double.infinity,
                          color: Color(0xffC7C7C7),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
