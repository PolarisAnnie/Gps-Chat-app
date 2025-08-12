import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/providers/viewmodels/auth_viewmodel.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';

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
    ref.read(authViewModelProvider.notifier).updateNickname(inputText);
  }

  void _onEnterPressed() async {
    final authState = ref.read(authViewModelProvider); // 현재 상태를 읽어옴
    final authNotifier = ref.read(authViewModelProvider.notifier);
    final nickname = authState.nickname;

    if (!authState.isNicknameValid) return; // 닉네임이 유효하지 않으면 종료

    // 닉네임 중복체크
    if (nickname != null) {
      // 로딩 시작
      authNotifier.setLoading(true);

      try {
        final nicknameExists = await authNotifier.checkNicknameExists(nickname);

        if (nicknameExists) {
          // 닉네임이 존재하는 경우, 위치설정이 안된 유저인지 확인
          final isIncomplete = await authNotifier.isIncompleteUser(nickname);

          if (isIncomplete) {
            // 위치설정만 안한 유저인 경우, 실제 User 객체를 가져와서 위치설정 페이지로 이동
            final user = await authNotifier.getUserByNickname(nickname);
            if (mounted && user != null) {
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: const Text('이어서 진행'),
                    content: const Text('\n입력하시던 정보가 있습니다.\n위치 설정 페이지로 이동합니다.'),
                    actions: [
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text(
                          '확인',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          // 현재 다이얼로그 닫기
                          Navigator.pop(context);
                          // 로그인 성공 시 현재 사용자 ID 저장 (위치 설정 전에)
                          UserRepository().setCurrentUserId(user.userId);
                          // 위치 설정 페이지로 이동
                          Navigator.pushReplacementNamed(
                            context,
                            '/location',
                            arguments: user,
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            }
          } else {
            // 완전한 유저인 경우, 홈화면으로 이동
            final user = await authNotifier.getUserByNickname(nickname);
            if (mounted && user != null) {
              // 로그인 성공 시 현재 사용자 ID 저장
              await UserRepository().setCurrentUserId(user.userId);
              Navigator.pushReplacementNamed(
                context,
                '/main',
                arguments: {'nickname': nickname},
              );
            }
          }
        } else {
          // 닉네임이 존재하지 않는 경우, 회원가입 다이얼로그 표시
          if (mounted) {
            showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text('첫 방문이시군요!'),
                  content: Text('\n회원가입하시겠습니까?'),
                  actions: [
                    CupertinoDialogAction(
                      child: Text(
                        '취소',
                        style: TextStyle(color: Colors.red.shade400),
                      ),
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
                          arguments: {'nickname': nickname},
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
      } catch (e) {
        // 에러 발생 시 사용자에게 알림
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('네트워크 오류가 발생했습니다. 다시 시도해주세요.')),
          );
        }
      } finally {
        // 로딩 종료
        authNotifier.setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

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
                          errorText: authState.errorMessage,
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
                            (authState.isNicknameValid && !authState.isLoading)
                            ? _onEnterPressed
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
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppTheme.textOnPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
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
