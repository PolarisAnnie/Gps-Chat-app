import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gps_chat_app/core/utils/location_utils.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/storage_repository.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';

class LocationSettings extends StatefulWidget {
  final Map<String, dynamic> userData;

  const LocationSettings({super.key, required this.userData});

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

  // _onStartButtonPressed 메서드
  void _onStartButtonPressed() async {
    if (!_isButtonEnabled || _isLoading || _currentPosition == null) return;

    setState(() {
      _isLoading = true;
    });

    // 1. Firestore에서 미리 고유한 userId를 생성
    final userId = FirebaseFirestore.instance.collection('users').doc().id;

    // 2. 프로필 이미지를 Firebase Storage에 업로드
    final imageUrl = await _storageRepository.uploadProfileImage(
      filePath: widget.userData['imagePath'], // RegisterPage에서 넘겨받은 로컬 경로
      userId: userId,
    );

    // 3. 이미지 업로드 실패 시, 사용자에게 알리고 함수 종료
    if (imageUrl == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('프로필 이미지 업로드에 실패했습니다.')));
      return;
    }

    // 4. 모든 정보(업로드된 이미지 URL, 위치 정보 등)를 포함하여 User 객체 생성
    final newUser = User(
      userId: userId,
      nickname: widget.userData['nickname'],
      introduction: widget.userData['introduction'],
      imageUrl: imageUrl,
      location: GeoPoint(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      ),
      address: _locationAddress,
    );

    // 5. UserRepository를 사용하여 Firestore에 사용자 정보 저장
    final bool isSuccess = await _userRepository.addUser(newUser);

    setState(() {
      _isLoading = false;
    });

    if (isSuccess) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false, // 모든 이전 화면 제거
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('사용자 정보를 저장하는 데 실패했습니다.')));
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
                    // FileImage를 사용하여 로컬 이미지 표시
                    backgroundImage: widget.userData['imagePath'] != null
                        ? FileImage(File(widget.userData['imagePath']))
                        : AssetImage('assets/images/profile_grey.png')
                              as ImageProvider,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      '${widget.userData['nickname']}님의\n위치 정보 가져오기',
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
