import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/providers/viewmodels/main_navigation_viewmodel.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_view_model.dart';
import 'package:gps_chat_app/ui/pages/chat/widgets/chat_bottom_sheet.dart';
import 'package:gps_chat_app/ui/pages/chat/widgets/chat_recieve_item.dart';
import 'package:gps_chat_app/ui/pages/chat/widgets/chat_send_item.dart';

// 상대방 사용자 정보 조회 Provider
final otherUserProvider = FutureProvider.family<User?, String>((
  ref,
  userId,
) async {
  return await UserRepository().getUserById(userId);
});

class ChatPage extends ConsumerStatefulWidget {
  final String roomId;
  final String otherUserId;

  ChatPage({required this.roomId, required this.otherUserId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  @override
  void initState() {
    super.initState();
    print('🔴 ChatPage initState 시작 - roomId: ${widget.roomId}');

    // ✅ 변경: 채팅방 진입 시 메시지 스트림 시작
    Future.microtask(() async {
      try {
        final user = await UserRepository().getCurrentUser();
        if (user != null && mounted) {
          print('🔴 사용자 정보 로딩 완료: ${user.nickname}');
          final viewModel = ref.read(
            chatPageViewModelProvider(widget.roomId).notifier,
          );
          viewModel.setCurrentUser(user);
          viewModel.startMessageStream(); // ✅ 실시간 메시지 스트림 시작
          print('🔴 startMessageStream 호출 완료');
        }
      } catch (e) {
        print('🔴 사용자 정보 로딩 실패: $e');
      }
    });
  }

  @override
  void dispose() {
    // 채팅방 나갈 때 메시지 스트림 정리
    ref
        .read(chatPageViewModelProvider(widget.roomId).notifier)
        .stopMessageStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatPageViewModelProvider(widget.roomId));
    print('🔴 ChatPage build - 메시지 수: ${state.messages.length}');
    final viewModel = ref.read(
      chatPageViewModelProvider(widget.roomId).notifier,
    );

    // 상대방 사용자 정보 조회
    final otherUserAsync = ref.watch(otherUserProvider(widget.otherUserId));
    final otherUser = otherUserAsync.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );

    // 현재 사용자
    final currentUser = viewModel.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(otherUser?.nickname ?? '채팅'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/main', (route) => false);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final navigationViewModel = ref.read(
                mainNavigationViewModelProvider.notifier,
              );
              navigationViewModel.changeTab(1); // 채팅 탭으로 변경
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          itemCount: state.messages.length,
          itemBuilder: (context, index) {
            final message = state.messages[index];
            final isMyMessage = viewModel.isMyMessage(message);

            return Column(
              children: [
                SizedBox(height: index == 0 ? 10 : 14),
                isMyMessage
                    ? ChatSendItem(
                        imageUrl: currentUser?.imageUrl ?? '',
                        nickname: currentUser?.nickname ?? 'Me',
                        content: message.content,
                        message: message,
                      )
                    : ChatReceiveItem(
                        imageUrl: otherUser?.imageUrl ?? '',
                        nickname: otherUser?.nickname ?? 'Unknown',
                        content: message.content,
                        message: message,
                      ),
                if (index == state.messages.length - 1) SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
      bottomSheet: ChatBottomSheet(
        MediaQuery.of(context).padding.bottom,
        widget.roomId,
      ),
    );
  }
}
