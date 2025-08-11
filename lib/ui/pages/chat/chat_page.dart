import 'package:flutter/material.dart';
import 'package:gps_chat_app/data/model/chat_message.dart';
import 'package:gps_chat_app/ui/pages/chat/widgets/chat_bottom_sheet.dart';
import 'package:gps_chat_app/ui/pages/chat/widgets/chat_recieve_item.dart';
import 'package:gps_chat_app/ui/pages/chat/widgets/chat_send_item.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatMessage> messages = [];
  void onSendMessage(String content) {
    // 새 메시지 추가 함수
    setState(() {
      messages.add(
        ChatMessage(
          chatId: 2, //TODO: 자동 생성
          content: content,
          createdAt: DateTime.now(),
          isSent: true, // TODO: 내가 보낸 메시지
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('받는 사람 이름')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          //TODO: 하드코딩된 부분 수정 및 메시지 업로드 시 화면 업데이트 필요함
          children: [
            SizedBox(height: 10),
            ChatSendItem(
              imageUrl: '',
              content: '안녕하세요안녕하세요안녕안녕안녕안녕안녕안녕안녕안녕안녕',
              dateTime: DateTime.now(),
            ),
            SizedBox(height: 14),
            ChatReceiveItem(
              imageUrl: '',
              content: '안녕하세요안녕하세요안녕안녕안녕안녕안녕안녕안녕안녕안녕',
              dateTime: DateTime.now(),
            ),
            SizedBox(height: 10),
            ChatReceiveItem(
              imageUrl: '',
              content: '반가워염',
              dateTime: DateTime.now(),
            ),
            SizedBox(height: 14),
            ChatSendItem(
              imageUrl: '',
              content: '안녕하세요안녕하세요안녕안녕안녕안녕안녕안녕안녕안녕안녕',
              dateTime: DateTime.now(),
            ),
          ],
        ),
      ),
      bottomSheet: ChatBottomSheet(
        MediaQuery.of(context).padding.bottom,
        onSendMessage,
      ),
    );
  }
}
