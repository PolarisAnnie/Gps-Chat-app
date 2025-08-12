import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/ui/pages/welcome/auth/signup_page.dart';

// 앱 첫 실행 시 보여지는 스플래시 페이지
// 애니메이션과 함께 앱의 로고와 이름을 보여줌
// 소린의 노가다와 피땀눈물
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController catMoveController;
  late AnimationController devController;
  late AnimationController potController;
  late AnimationController bubbleController;

  late Animation<Offset> devOffsetAnimation;
  late Animation<double> devScaleAnimation;

  late Animation<Offset> potOffsetAnimation;
  late Animation<double> potScaleAnimation;

  late Animation<Offset> bubbleOffsetAnimation;
  late Animation<double> bubbleScaleAnimation;

  @override
  void initState() {
    super.initState();
    catMoveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    devController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    potController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 애니메이션 정의
    devOffsetAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: devController, curve: Curves.easeOutBack),
        );
    devScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: devController, curve: Curves.easeOutBack),
    );
    potOffsetAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: potController, curve: Curves.easeOutBack),
        );
    potScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: potController, curve: Curves.easeOutBack),
    );
    bubbleOffsetAnimation =
        Tween<Offset>(begin: const Offset(-0.5, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: bubbleController, curve: Curves.easeOutBack),
        );
    bubbleScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: bubbleController, curve: Curves.easeOutBack),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      devController.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      potController.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      bubbleController.forward();

      // 3초 후 다음 화면으로 이동
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignupPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    catMoveController.dispose();
    devController.dispose();
    potController.dispose();
    bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: screenHeight * 0.4,
            child: Image.asset(
              'assets/images/base_circle.png',
              height: screenHeight * 0.05,
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.45,
            child: AnimatedBuilder(
              animation: catMoveController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 10 * (catMoveController.value - 0.5)),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/catpot.png',
                height: screenHeight * 0.2,
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: devOffsetAnimation,
                  child: ScaleTransition(
                    scale: devScaleAnimation,
                    child: const Text(
                      'dev',
                      style: TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                SlideTransition(
                  position: potOffsetAnimation,
                  child: ScaleTransition(
                    scale: potScaleAnimation,
                    child: const Text(
                      'pot',
                      style: TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.6,
            right: screenWidth * 0.15,
            child: SlideTransition(
              position: bubbleOffsetAnimation,
              child: ScaleTransition(
                scale: bubbleScaleAnimation,
                child: Image.asset(
                  'assets/images/code_bubble.png',
                  width: 60,
                  height: 60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
