import 'package:flutter/material.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/data/model/user_model.dart';

class ProfileCard extends StatelessWidget {
  final User user;
  final VoidCallback? onImageTap;
  final bool isEditing;
  final bool isSaving;

  const ProfileCard({
    super.key,
    required this.user,
    this.onImageTap,
    this.isEditing = false,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 프로필 이미지
          GestureDetector(
            onTap: isEditing ? onImageTap : null,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
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
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: isSaving
                          ? const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_outlined,
                              size: 18,
                              color: AppTheme.primaryColor,
                            ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 닉네임
          Text(
            user.nickname,
            style: const TextStyle(
              fontFamily: 'Paperlogy',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
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
