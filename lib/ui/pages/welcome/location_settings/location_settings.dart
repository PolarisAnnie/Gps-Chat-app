import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/core/providers/viewmodels/location_viewmodel.dart';
import 'package:gps_chat_app/data/model/user_model.dart';

class LocationSettings extends ConsumerStatefulWidget {
  final User user;
  //홈에서 왔는지 확인하는 플래그 추가
  final bool isFromHomePage;

  const LocationSettings({
    super.key,
    required this.user,
    this.isFromHomePage = false,
  });

  @override
  ConsumerState<LocationSettings> createState() => _LocationSettingsState();
}

class _LocationSettingsState extends ConsumerState<LocationSettings> {
  // Location utils로 현재 위치 가져오는 메서드
  Future<void> _fetchLocation() async {
    await ref.read(locationViewModelProvider.notifier).fetchLocation();
  }

  // _onStartButtonPressed 메서드 (정보를 업데이트하도록 변경)
  void _onStartButtonPressed() async {
    final viewModel = ref.read(locationViewModelProvider.notifier);
    final isSuccess = await viewModel.updateUserLocation(widget.user.userId);

    if (isSuccess && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('위치 정보가 업데이트되었습니다!')));

      // isFromHomePage 값에 따라 다른 동작 수행
      if (widget.isFromHomePage) {
        // 홈에서 왔다면, 이전 페이지(홈)로 돌아가기
        Navigator.pop(context);
      } else {
        // 최초 설정 플로우라면, 메인 페이지로 이동
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    } else if (mounted) {
      final state = ref.read(locationViewModelProvider);
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      }
    }
  }

  // 뒤로가기 버튼을 눌렀을 때 다이얼로그 표시
  Future<bool> _onBackPressed(BuildContext context) async {
    bool? goBack = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('페이지를 나가시겠어요?'),
        content: const Text('\n입력하신 닉네임은 저장됩니다.\n나중에 다시 돌아와 위치를 설정할 수 있어요.'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('계속 설정하기'),
            onPressed: () =>
                Navigator.of(context).pop(false), // 다이얼로그를 닫고 페이지에 머무름
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('나가기'),
            onPressed: () {
              // 현재 다이얼로그 닫기
              Navigator.pop(context);
              //  페이지로 이동
              Navigator.pushReplacementNamed(
                context,
                '/signup', // 페이지를 나가는 것을 허용
              );
            },
          ),
        ],
      ),
    );
    return goBack ?? false; // 사용자가 다이얼로그 바깥을 탭하는 등 아무 선택도 안하면 나가지 않음
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationViewModelProvider);
    //홈에서 왔을 때와 아닐 때를 구분하는 변수
    final bool isResettng = widget.isFromHomePage;

    return PopScope(
      canPop: isResettng, // 홈에서 왔으면 뒤로가기 허용
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onBackPressed(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isResettng ? '위치 재설정' : '위치 설정'),
          centerTitle: true,
          // 홈에서 온 것이 아니라면, 기본 뒤로가기 버튼을 숨겨 PopScope가 제어하도록 함
          automaticallyImplyLeading: isResettng,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),

                // 상단 프로필 UI (circle avatar 부분은 로컬 이미지를 보여주도록 수정할수도 있음!)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      // networkImage를 사용하여 전달받은 User 객체의 이미지 경로를 사용
                      backgroundImage: NetworkImage(widget.user.imageUrl),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        // User 객체로부터 닉네임 가져와서 표시
                        '${widget.user.nickname}님의\n위치 정보 가져오기',
                        style: TextStyle(
                          fontSize: AppTheme.titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),

                // 위치 정보 표시 영역!
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재 위치',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      // padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: state.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : Row(
                              children: [
                                Text(
                                  state.address,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: state.isButtonEnabled
                                        ? AppTheme.textPrimary
                                        : AppTheme.textTertiary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // SizedBox(width: 8),
                                Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.location_on,
                                    color: AppTheme.primaryColor,
                                    size: 30,
                                  ),
                                  onPressed: state.isLoading
                                      ? null
                                      : _fetchLocation,
                                ),
                              ],
                            ),
                    ),
                    // SizedBox(height: 16),
                    // Row(children: [Expanded(child: Divider(thickness: 1.5))]),
                  ],
                ),

                Spacer(),
                //시작하기 버튼
                ElevatedButton(
                  onPressed: state.isButtonEnabled && !state.isLoading
                      ? _onStartButtonPressed // 여기서 수정한 map 핀버튼 함수 연결됨
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.textOnPrimary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBackgroundColor: Colors.grey.shade600,
                  ),
                  child: state.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.textOnPrimary,
                            strokeWidth: 3.0,
                          ),
                        )
                      : Text(
                          isResettng ? '저장하기' : '시작하기', // 버튼 텍스트 변경
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textOnPrimary,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
