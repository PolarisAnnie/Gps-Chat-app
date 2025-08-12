import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/providers/viewmodels/main_navigation_viewmodel.dart';
import 'package:gps_chat_app/data/model/chat_message.dart';
import 'package:gps_chat_app/ui/pages/profile/profile_page.dart';

class ChatSendItem extends ConsumerWidget {
  ChatSendItem({
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                nickname,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Container(
                  decoration: BoxDecoration(
                    color: (Color(0xff3266FF)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    content,
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
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
        SizedBox(width: 8),
        SizedBox(
          height: 32,
          width: 32,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true, // 모달 스타일로 표시
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text('내 프로필'),
                      leading: IconButton(
                        icon: Icon(Icons.close), // X 버튼
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    body: ProfilePage(),
                  ),
                ),
              );
            },
            child: ClipOval(
              child: Image.network(
                imageUrl.isEmpty ? 'https://picsum.photos/320/320' : imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
