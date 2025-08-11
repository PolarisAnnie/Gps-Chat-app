import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/core/providers/viewmodels/register_viewmodel.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final String nickname;
  const RegisterPage({super.key, required this.nickname});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _introController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nicknameController.text = widget.nickname;
    _nicknameController.addListener(_onTextChanged);
    _introController.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(registerViewModelProvider.notifier).setNickname(widget.nickname);
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _introController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final viewModel = ref.read(registerViewModelProvider.notifier);
    viewModel.setNickname(_nicknameController.text);
    viewModel.setIntroduction(_introController.text);
  }

  Future<void> _pickImage() async {
    await ref.read(registerViewModelProvider.notifier).pickImage();
  }

  void _onNextPressed() async {
    final viewModel = ref.read(registerViewModelProvider.notifier);
    final newUser = await viewModel.registerUser();

    if (newUser != null && mounted) {
      Navigator.pushNamed(context, '/location', arguments: newUser);
    } else if (mounted) {
      final errorMessage = ref.read(registerViewModelProvider).errorMessage;
      if (errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerViewModelProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('회원가입'), centerTitle: true),
        body: SafeArea(
          child: Column(
            children: [
              // 프로필 이미지 선택
              Container(
                color: AppTheme.primaryColor,
                height: 180,
                // padding: const EdgeInsets.all(32),
                child: Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFFdedede),
                          backgroundImage: state.profileImage != null
                              ? FileImage(state.profileImage!)
                              : null,
                          child: state.profileImage == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFF535353),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF98b2ff),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: AppTheme.textOnPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: ListView(
                    children: [
                      // const SizedBox(height: 40),
                      // 닉네임 입력
                      TextField(
                        controller: _nicknameController,
                        decoration: InputDecoration(
                          labelText: '닉네임',
                          labelStyle: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          hintText: '사용할 이름을 입력해주세요',
                          hintStyle: TextStyle(color: AppTheme.textTertiary),
                          border: const UnderlineInputBorder(),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const SizedBox(
                        child: Text(
                          '소개',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 소개글 입력
                      TextField(
                        controller: _introController,
                        decoration: InputDecoration(
                          hintText: '가볍게 나에 대한 소개를 작성해주세요',
                          hintStyle: TextStyle(color: AppTheme.textTertiary),
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
              ),
              // 다음 단계로 이동 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isFormValid && !state.isLoading
                      ? _onNextPressed
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.textOnPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '다음 단계로',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
