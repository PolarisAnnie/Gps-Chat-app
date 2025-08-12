import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_view_model.dart';

class ChatBottomSheet extends ConsumerStatefulWidget {
  const ChatBottomSheet(this.bottomPadding, this.roomId, {super.key});

  final double bottomPadding;
  final String roomId;

  @override
  ConsumerState<ChatBottomSheet> createState() => _ChatDetailBottomSheetState();
}

class _ChatDetailBottomSheetState extends ConsumerState<ChatBottomSheet> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(onTextChanged);
  }

  @override
  void dispose() {
    controller.removeListener(onTextChanged);
    controller.dispose();
    super.dispose();
  }

  // 텍스트 변화 감지
  void onTextChanged() {
    final viewModel = ref.read(
      chatPageViewModelProvider(widget.roomId).notifier,
    );
    viewModel.onTextChanged(controller.text);
  }

  // 메시지 전송
  void onSend() {
    final viewModel = ref.read(
      chatPageViewModelProvider(widget.roomId).notifier,
    );
    viewModel.onSendPressed();
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatPageViewModelProvider(widget.roomId));
    final hasText = state.newMessageText.trim().isNotEmpty;
    final viewModel = ref.read(
      chatPageViewModelProvider(widget.roomId).notifier,
    );

    return Container(
      height: 70 + widget.bottomPadding,
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xffEFF1F5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: viewModel.onTextChanged,
                      decoration: InputDecoration(
                        hintText: "Message",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (v) => onSend(),
                    ),
                  ),

                  GestureDetector(
                    onTap: hasText && !state.isSending ? onSend : null,
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.send,
                        color: hasText
                            ? Color(0xff3266FF) // 파란색
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: widget.bottomPadding),
        ],
      ),
    );
  }
}
