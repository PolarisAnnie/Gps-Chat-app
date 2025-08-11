import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_view_model.dart';
import 'package:gps_chat_app/ui/pages/chat/widgets/chat_bottom_sheet.dart';
import 'package:gps_chat_app/ui/pages/chat/widgets/chat_recieve_item.dart';
import 'package:gps_chat_app/ui/pages/chat/widgets/chat_send_item.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String roomId;
  const ChatPage({super.key, required this.roomId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatPageViewModelProvider(widget.roomId));
    final viewModel = ref.read(
      chatPageViewModelProvider(widget.roomId).notifier,
    );
    return Scaffold(
      appBar: AppBar(title: Text('받는 사람 이름')),
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
                        imageUrl: '',
                        content: message.content,
                        dateTime: message.createdAt,
                      )
                    : ChatReceiveItem(
                        imageUrl: '',
                        content: message.content,
                        dateTime: message.createdAt,
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
