import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/core/providers/viewmodels/location_viewmodel.dart';
import 'package:gps_chat_app/data/model/user_model.dart';

class LocationSettings extends ConsumerStatefulWidget {
  final User user;

  const LocationSettings({super.key, required this.user});

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
      // 성공적으로 업데이트되면 홈 화면으로 이동
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (route) => false, // 모든 이전 화면 제거
      );
    } else if (mounted) {
      final state = ref.read(locationViewModelProvider);
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text('위치 설정'), centerTitle: true),
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
                    ? _onStartButtonPressed
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.textOnPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
                        '시작하기',
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
    );
  }
}
