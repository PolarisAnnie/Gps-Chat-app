import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/data/model/chat_message.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_page.dart';
import 'package:gps_chat_app/ui/pages/home/member_detail.dart';

class ChatReceiveItem extends ConsumerWidget {
  ChatReceiveItem({
    required this.imageUrl,
    required this.nickname,
    required this.content,
    required this.message,
  });

  final String imageUrl;
  final String nickname;
  final String content;
  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 32,
          width: 32,
          child: GestureDetector(
            onTap: () async {
              final otherUser = await ref.read(
                otherUserProvider(message.senderId).future,
              );

              if (otherUser != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemberDetailPage(user: otherUser),
                  ),
                );
              }
            },
            child: ClipOval(
              child: Image.network(
                imageUrl.isEmpty ? 'https://picsum.photos/320/320' : imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nickname,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(right: 60),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(content, style: TextStyle(fontSize: 13)),
                ),
              ),
              SizedBox(height: 3),
              Text(
                message.formattedTime,
                style: TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
