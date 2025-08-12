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
    if (currentUser.userId == chatRoom.currentUserId) {
      return chatRoom.otherUserId;
    } else {
      return chatRoom.currentUserId;
    }
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

  // 앱 복귀 시 채팅방 리스트 강제 갱신
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restartChatRoomsStream();
    }
  }

  void _restartChatRoomsStream() {
    final vm = ref.read(chatRoomListViewModelProvider.notifier);
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      vm.refreshChatRooms(
        userId: currentUser.userId,
        address: currentUser.address ?? '',
      );
      print('🟦 채팅방 리스트 스트림 재시작');
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
            ref
                .read(chatRoomListViewModelProvider.notifier)
                .refreshChatRooms(
                  userId: user.userId,
                  address: user.address ?? '',
                );
            print('🟦 초기화 완료');
          });
        }

        // 채팅탭 재진입 시 스트림 재시작
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            _restartChatRoomsStream();
          }
        });

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
            child: state.isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
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
                                ).then((_) {
                                  _restartChatRoomsStream();
                                });
                              },
                              child: ChatRoomItem(
                                chatRoom: state.chatRooms[index],
                              ),
                            ),
                            SizedBox(height: 12),
                            if (index < state.chatRooms.length - 1)
                              Container(
                                height: 0.3,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xffC7C7C7),
                                ),
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
