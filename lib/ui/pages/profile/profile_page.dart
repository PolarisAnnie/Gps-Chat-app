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
      return _buildErrorState(viewModel);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          ProfileCard(user: state.user!),
          const SizedBox(height: 32),
          if (!state.isEditing) ...[
            _buildEditButton(viewModel),
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

  Widget _buildErrorState(ProfileViewModel viewModel) {
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
              '사용자 정보를 찾을 수 없습니다',
              style: TextStyle(
                fontFamily: 'Paperlogy',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '네트워크 연결을 확인해주세요',
              style: TextStyle(
                fontFamily: 'Paperlogy',
                fontSize: 14,
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.loadUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '다시 시도',
                style: TextStyle(
                  fontFamily: 'Paperlogy',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
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
