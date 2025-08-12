import 'package:flutter/material.dart';
import 'package:gps_chat_app/core/theme/theme.dart';

class ProfileEditForm extends StatefulWidget {
  final String initialNickname;
  final String initialIntroduction;
  final String? nicknameError;
  final bool isSaving;
  final Function(String nickname, String introduction) onSave;
  final VoidCallback onCancel;

  const ProfileEditForm({
    super.key,
    required this.initialNickname,
    required this.initialIntroduction,
    this.nicknameError,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  late final TextEditingController _nicknameController;
  late final TextEditingController _introductionController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.initialNickname);
    _introductionController = TextEditingController(
      text: widget.initialIntroduction,
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 닉네임 입력
        const Text(
          '닉네임',
          style: TextStyle(
            fontFamily: 'Paperlogy',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nicknameController,
          decoration: InputDecoration(
            hintText: '닉네임을 입력하세요',
            hintStyle: TextStyle(
              fontFamily: 'Paperlogy',
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.all(16),
            errorText: widget.nicknameError,
          ),
          style: const TextStyle(fontFamily: 'Paperlogy', fontSize: 16),
          maxLength: 20,
        ),
        // const SizedBox(height: 4),
        // 소개 입력
        const Text(
          '소개',
          style: TextStyle(
            fontFamily: 'Paperlogy',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _introductionController,
          maxLines: 3,
          maxLength: 100,
          onChanged: (value) {
            if (value.length > 100) {
              _introductionController.text = value.substring(0, 100);
              _introductionController.selection = TextSelection.fromPosition(
                TextPosition(offset: _introductionController.text.length),
              );
            }
          },
          decoration: InputDecoration(
            hintText: '자신을 소개해보세요',
            hintStyle: TextStyle(
              fontFamily: 'Paperlogy',
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: const TextStyle(
              fontFamily: 'Paperlogy',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          style: const TextStyle(fontFamily: 'Paperlogy', fontSize: 16),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            // 취소 버튼(왼쪽)
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: widget.onCancel,

                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                      side: const BorderSide(
                        color: AppTheme.textSecondary, // 테두리 색상
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      fontFamily: 'Paperlogy',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 저장하기 버튼
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.isSaving
                      ? null
                      : () => widget.onSave(
                          _nicknameController.text,
                          _introductionController.text,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isSaving
                        ? Colors.grey
                        : AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: widget.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          '저장하기',
                          style: TextStyle(
                            fontFamily: 'Paperlogy',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
