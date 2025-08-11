import 'package:flutter/material.dart';
import 'package:gps_chat_app/data/model/user_model.dart';

class MemberDetailPage extends StatefulWidget {
  final User user;
  const MemberDetailPage({super.key, required this.user});

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '상세 소개',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 343,
              height: 212,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                image: user.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(user.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 23),
          Padding(
            padding: const EdgeInsets.only(left: 22.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                user.nickname,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Text(
                user.introduction.isNotEmpty ? user.introduction : '소개가 없습니다.',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 22.0),
            child: GestureDetector(
              onTap: () {
                // TODO: Implement chat start logic here
              },
              child: Container(
                width: 138,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF3266FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.only(left: 26.0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '채팅 시작하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
