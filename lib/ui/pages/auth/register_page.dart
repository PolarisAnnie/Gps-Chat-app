import 'package:flutter/material.dart';
<<<<<<< HEAD
<<<<<<< HEAD
=======
import 'package:flutter/cupertino.dart';
>>>>>>> dev
=======
import 'package:flutter/cupertino.dart';
>>>>>>> dev
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

  Future<bool> _onWillPop() async {
    final state = ref.read(registerViewModelProvider);

    // 작성된 내용이 있는지 확인
    bool hasContent =
        state.nickname.isNotEmpty ||
        state.introduction.isNotEmpty ||
        state.profileImage != null;

    if (!hasContent) {
      return true; // 작성된 내용이 없으면 바로 나가기
    }

    // 작성된 내용이 있으면 경고 다이얼로그 표시
    return await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('나가시겠습니까?'),
            content: Text('\n작성중인 내용이 사라집니다.'),
            actions: [
              CupertinoDialogAction(
                child: Text('취소', style: TextStyle(color: Colors.blue)),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                child: Text(
                  '나가기',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  // 작성중인 내용 초기화
                  ref.read(registerViewModelProvider.notifier).clearData();
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        ) ??
        false; // null인 경우 false 반환
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerViewModelProvider);

<<<<<<< HEAD
<<<<<<< HEAD
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
=======
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: GestureDetector(
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
                            radius: 56,
                            backgroundColor: Color(0xFFdedede),
                            backgroundImage: state.profileImage != null
                                ? FileImage(state.profileImage!)
                                : null,
                            child: state.profileImage == null
                                ? Icon(
                                    Icons.person,
                                    size: 56,
                                    color: Color(0xFF535353),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Color(0xFF98b2ff),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
                                color: AppTheme.textOnPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
=======
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: GestureDetector(
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
                            radius: 56,
                            backgroundColor: Color(0xFFdedede),
                            backgroundImage: state.profileImage != null
                                ? FileImage(state.profileImage!)
                                : null,
                            child: state.profileImage == null
                                ? Icon(
                                    Icons.person,
                                    size: 56,
                                    color: Color(0xFF535353),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Color(0xFF98b2ff),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
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
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isFormValid && !state.isLoading
                          ? _onNextPressed
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        disabledBackgroundColor: Colors.grey.shade600,
                        disabledForegroundColor: Colors.white,
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
>>>>>>> dev
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
>>>>>>> dev
                        ),
                      ],
                    ),
                  ),
                ),
<<<<<<< HEAD
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
=======
                // 다음 단계로 이동 버튼
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isFormValid && !state.isLoading
                          ? _onNextPressed
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        disabledBackgroundColor: Colors.grey.shade600,
                        disabledForegroundColor: Colors.white,
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
>>>>>>> dev
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
