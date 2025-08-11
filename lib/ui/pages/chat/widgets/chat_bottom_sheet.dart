import 'package:flutter/material.dart';

class ChatBottomSheet extends StatefulWidget {
  const ChatBottomSheet(this.bottomPadding, this.onSend, {super.key});

  final double bottomPadding;
  final Function(String) onSend;

  @override
  State<ChatBottomSheet> createState() => _ChatDetailBottomSheetState();
}

class _ChatDetailBottomSheetState extends State<ChatBottomSheet> {
  final controller = TextEditingController();
  bool hasText = false;

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

  // 텍스트 변화 감지 함수
  void onTextChanged() {
    final bool newHasText = controller.text.trim().isNotEmpty;
    if (newHasText != hasText) {
      setState(() {
        hasText = newHasText;
      });
    }
  }

  void onSend() {
    if (!hasText) return;
    //TODO : 채팅 업로드 함수
    print('채팅 업로드');
    widget.onSend(controller.text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
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
                      decoration: InputDecoration(
                        hintText: "Message",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                      ),
                      controller: controller,
                      onSubmitted: (v) => onSend(),
                    ),
                  ),

                  GestureDetector(
                    onTap: hasText ? onSend : null,
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
