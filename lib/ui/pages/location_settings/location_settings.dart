import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gps_chat_app/core/utils/location_utils.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/storage_repository.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';

class LocationSettings extends StatefulWidget {
  final User user;

  const LocationSettings({super.key, required this.user});

  @override
  State<LocationSettings> createState() => _LocationSettingsState();
}

class _LocationSettingsState extends State<LocationSettings> {
  final UserRepository _userRepository = UserRepository();
  final StorageRepository _storageRepository = StorageRepository();

  String _locationAddress = '위치 정보를 가져와주세요.';
  Position? _currentPosition;
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  // Location utils로 현재 위치 가져오는 메서드
  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
    });

    final locationData = await LocationUtils.getCurrentLocationData();

    setState(() {
      if (locationData != null) {
        // 위치 정보가 유효한 경우
        _locationAddress = locationData.address;
        _currentPosition = locationData.position;
        _isButtonEnabled = true; // 위치 정보가 유효하면 버튼 활성화
      } else {
        _locationAddress = '위치를 가져올 수 없습니다. 권한을 확인해주세요.';
        _isButtonEnabled = false;
      }
      _isLoading = false;
    });
  }

  // _onStartButtonPressed 메서드 (정보를 업데이트하도록 변경)
  void _onStartButtonPressed() async {
    if (!_isButtonEnabled || _isLoading || _currentPosition == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. 새로운 위치 정보 생성
      final newLocation = GeoPoint(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // 2. UserRepository를 사용하여 Firestore에 사용자 정보 업데이트
      final bool isSuccess = await _userRepository.updateUserLocation(
        userId: widget.user.userId,

        location: newLocation,
        address: _locationAddress,
      );

      if (isSuccess) {
        // 3. 성공적으로 업데이트되면 홈 화면으로 이동
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false, // 모든 이전 화면 제거
        );
      } else {
        throw Exception('위치 정보 업데이트에 실패했습니다.');
      }
    } catch (e) {
      print('위치 정보 업데이트 중 오류 발생: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('위치 정보 업데이트 중 오류가 발생했습니다.')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '위치 설정',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
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
                    backgroundImage: widget.user.imageUrl != null
                        ? NetworkImage(widget.user.imageUrl)
                        : AssetImage('assets/images/profile_grey.png')
                              as ImageProvider,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      // User 객체로부터 닉네임 가져와서 표시
                      '${widget.user.nickname}님의\n위치 정보 가져오기',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Row(
                            children: [
                              Text(
                                _locationAddress,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: _isButtonEnabled
                                      ? Colors.black
                                      : Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              // SizedBox(width: 8),
                              Spacer(),
                              IconButton(
                                icon: Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                                onPressed: _isLoading ? null : _fetchLocation,
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
                onPressed: _isButtonEnabled && !_isLoading
                    ? _onStartButtonPressed
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  disabledBackgroundColor: Colors.grey.shade600,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3.0,
                        ),
                      )
                    : Text(
                        '시작하기',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
