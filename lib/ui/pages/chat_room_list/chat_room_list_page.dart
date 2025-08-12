import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_page.dart';
import 'package:gps_chat_app/ui/pages/chat_room_list/chat_room_list_view_model.dart';
import 'package:gps_chat_app/ui/pages/chat_room_list/widgets/chat_room_item.dart';

class ChatRoomListPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ChatRoomListPage> createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends ConsumerState<ChatRoomListPage> {
  bool _initialized = false; // 중복 실행 방지

  // 상대방 ID를 결정하는 메서드
  String _getOtherUserId(ChatRoom chatRoom, User currentUser) {
    if (currentUser.userId == chatRoom.currentUserId) {
      return chatRoom.otherUserId; // 내가 시작한 채팅방
    } else {
      return chatRoom.currentUserId; // 상대방이 시작한 채팅방
    }
  }

  @override
  void initState() {
    super.initState();
    // _initializeData() 호출 제거 - data 섹션에서만 호출
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
        // 🎯 사용자 정보 로딩 완료 후에만 초기화!
        if (user != null && !_initialized) {
          _initialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final viewModel = ref.read(chatRoomListViewModelProvider.notifier);
            print('🔍 로딩된 사용자 - userId: ${user.userId}');
            print('🔍 로딩된 사용자 - address: ${user.address}');

            viewModel.loadChatRooms();
            viewModel.startChatRoomsStream();
            print('🟦 초기화 완료');
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
                          // 올바른 상대방 ID 계산
                          final correctOtherUserId = _getOtherUserId(
                            chatRoom,
                            user!,
                          );

                          print('채팅방 클릭');
                          print(
                            '🟢 채팅방 클릭 - roomId: ${state.chatRooms[index].roomId}',
                          );
                          print('🟢 올바른 otherUserId: $correctOtherUserId');

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ChatPage(
                                  roomId: state.chatRooms[index].roomId,
                                  otherUserId: correctOtherUserId, // 수정된 부분
                                );
                              },
                            ),
                          );
                        },
                        child: ChatRoomItem(
                          chatRoom: state.chatRooms[index], // chatRoom 데이터 전달
                        ),
                      ),
                      SizedBox(height: 12),
                      if (index < state.chatRooms.length - 1)
                        Container(
                          height: 0.3,
                          width: double.infinity,
                          decoration: BoxDecoration(color: Color(0xffC7C7C7)),
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
