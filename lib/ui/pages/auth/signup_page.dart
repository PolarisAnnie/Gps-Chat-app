import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/providers/viewmodels/auth_viewmodel.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_validateNickname);
  }

  @override
  void dispose() {
    _nicknameController.removeListener(_validateNickname);
    _nicknameController.dispose();
    super.dispose();
  }

  void _validateNickname() {
    final inputText = _nicknameController.text;
    final authViewModel = ref.read(authViewModelProvider.notifier);

    authViewModel.setNickname(inputText);
    final error = authViewModel.validateNickname(inputText);
    authViewModel.setError(error);
  }

  void _onEnterPressed() {
    final inputText = _nicknameController.text;
    final authViewModel = ref.read(authViewModelProvider.notifier);

    if (!authViewModel.isNicknameValid) return; // 닉네임이 유효하지 않으면 종료

    // 닉네임 중복체크
    if (authViewModel.checkNicknameExists(inputText)) {
      // 중복된 닉네임인 경우, 홈화면으로 이동
      Navigator.pushReplacementNamed(
        context,
        '/main',
        arguments: {'nickname': inputText},
      );
    } else {
      // 중복되지 않은 닉네임인 경우, 프로필 설정 페이지로 이동
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('첫 방문이시군요!'),
            content: Text('\n회원가입하시겠습니까?'),
            actions: [
              CupertinoDialogAction(
                child: Text('취소', style: TextStyle(color: Colors.red.shade400)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // 회원가입 페이지로 이동
                  Navigator.pushNamed(
                    context,
                    '/register',
                    arguments: {'nickname': inputText},
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 키보드 내리기
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      // 좌측 상단 로고
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            text: '개발자',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '들을 위한\n지역 기반 소셜링',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 로고
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: double.infinity,
                        ),
                      ),
                      const Spacer(),
                      // 닉네임 입력 필드
                      TextField(
                        controller: _nicknameController,
                        decoration: InputDecoration(
                          labelText: '닉네임\n',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          isDense: false,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 0.0,
                          ),
                          errorText: ref
                              .watch(authViewModelProvider)
                              .errorMessage,
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 입장하기 버튼
                      ElevatedButton(
                        onPressed:
                            ref
                                .watch(authViewModelProvider.notifier)
                                .isNicknameValid
                            ? _onEnterPressed
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          disabledBackgroundColor: Colors.grey.shade600,
                          disabledForegroundColor: Colors.white,
                        ),

                        child: const Text(
                          '입장하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
