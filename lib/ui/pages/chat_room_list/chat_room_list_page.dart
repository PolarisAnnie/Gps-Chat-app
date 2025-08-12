import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_page.dart';
import 'package:gps_chat_app/ui/pages/chat_room_list/chat_room_list_view_model.dart';
import 'package:gps_chat_app/ui/pages/chat_room_list/widgets/chat_room_item.dart';

class ChatRoomListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatRoomListViewModelProvider);
    final viewModel = ref.read(chatRoomListViewModelProvider.notifier);

    // 진입 시 데이터 로딩
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.loadChatRooms();
      viewModel.startChatRoomsStream();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff3266FF),
        title: Text(
          '열린 채팅방 ${state.chatRooms.length}개',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                      print('채팅방 클릭');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ChatPage(
                              roomId: state.chatRooms[index].roomId,
                              otherUserId: state.chatRooms[index].otherUserId,
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
  }
}
