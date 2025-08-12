import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/ui/pages/profile/profile_view_model.dart';
import 'package:gps_chat_app/ui/pages/profile/widgets/profile_card.dart';
import 'package:gps_chat_app/ui/pages/profile/widgets/profile_edit_form.dart';
import 'package:gps_chat_app/ui/pages/profile/widgets/loading_widget.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);
    final profileViewModel = ref.read(profileViewModelProvider.notifier);

    // 에러 처리
    ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
      if (next.error != null) {
        _showSnackBar(context, next.error!, isError: true);
        profileViewModel.clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '프로필',
          style: TextStyle(
            fontFamily: 'Paperlogy',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(context, profileState, profileViewModel),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProfileState state,
    ProfileViewModel viewModel,
  ) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.user == null) {
      return _buildErrorState(context, viewModel);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          ProfileCard(user: state.user!),
          const SizedBox(height: 32),
          if (!state.isEditing) ...[
            _buildEditButton(viewModel),
            const SizedBox(height: 16),
            _buildLogoutButton(context, viewModel),
          ] else ...[
            ProfileEditForm(
              initialNickname: state.user!.nickname,
              initialIntroduction: state.user!.introduction,
              nicknameError: state.nicknameError,
              isSaving: state.isSaving,
              onSave: (nickname, introduction) async {
                final success = await viewModel.saveProfile(
                  nickname,
                  introduction,
                );
                if (success && context.mounted) {
                  _showSnackBar(context, '수정이 완료되었습니다.');
                }
              },
              onCancel: viewModel.cancelEditing,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditButton(ProfileViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: viewModel.startEditing,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          '수정하기',
          style: TextStyle(
            fontFamily: 'Paperlogy',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ProfileViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () => _showLogoutDialog(context, viewModel),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          '로그아웃',
          style: TextStyle(
            fontFamily: 'Paperlogy',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '로그아웃',
            style: TextStyle(
              fontFamily: 'Paperlogy',
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          content: const Text(
            '정말로 로그아웃하시겠습니까?',
            style: TextStyle(
              fontFamily: 'Paperlogy',
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'Paperlogy',
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await viewModel.logout();
                if (success && context.mounted) {
                  _showSnackBar(context, '로그아웃되었습니다.');
                  // 로그인 페이지로 이동
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/signup', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '로그아웃',
                style: TextStyle(
                  fontFamily: 'Paperlogy',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, ProfileViewModel viewModel) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '로그인이 필요합니다',
              style: TextStyle(
                fontFamily: 'Paperlogy',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '프로필을 보려면 먼저 로그인해주세요',
              style: TextStyle(
                fontFamily: 'Paperlogy',
                fontSize: 14,
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: viewModel.loadUserData,
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '다시 시도',
                      style: TextStyle(
                        fontFamily: 'Paperlogy',
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/signup', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '로그인하기',
                      style: TextStyle(
                        fontFamily: 'Paperlogy',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.error_outline : Icons.check,
                color: isError ? Colors.red : AppTheme.primaryColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Paperlogy',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : AppTheme.primaryColor,
        duration: Duration(seconds: isError ? 3 : 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
      ),
    );
  }
}
