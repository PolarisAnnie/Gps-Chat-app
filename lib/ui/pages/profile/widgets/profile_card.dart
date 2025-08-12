import 'package:flutter/material.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/data/model/user_model.dart';

class ProfileCard extends StatelessWidget {
  final User user;

  const ProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // 프로필 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipOval(
              child: user.imageUrl.isNotEmpty
                  ? Image.network(
                      user.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultProfileImage(),
                    )
                  : _buildDefaultProfileImage(),
            ),
          ),
          const SizedBox(height: 16),
          // 닉네임
          Text(
            user.nickname,
            style: const TextStyle(
              fontFamily: 'Paperlogy',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // 소개글
          Text(
            user.introduction.isEmpty ? 'Flutter를 공부중' : user.introduction,
            style: const TextStyle(
              fontFamily: 'Paperlogy',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultProfileImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.person, size: 40, color: Colors.grey),
    );
  }
}
