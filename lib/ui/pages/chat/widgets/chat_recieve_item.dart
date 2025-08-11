import 'package:flutter/material.dart';

class ChatReceiveItem extends StatelessWidget {
  const ChatReceiveItem({
    super.key,
    required this.imageUrl,
    required this.content,
    required this.dateTime,
  });

  final String imageUrl;
  final String content;
  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 32,
          width: 32,
          //decoration: BoxDecoration(shape: BoxShape.circle),
          child: GestureDetector(
            onTap: () {
              print('프로필 이미지 클릭');
            },
            child: ClipOval(
              child: Image.network(
                //TODO : firebase 프로필 이미지 URL로 연결
                'https://picsum.photos/320/320',
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
                '닉네임',
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
                dateTime.toIso8601String(),
                style: TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
