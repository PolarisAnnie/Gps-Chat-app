import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gps_chat_app/core/utils/location_utils.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';

class LocationSettings extends StatefulWidget {
  final Map<String, dynamic> userData;

  const LocationSettings({super.key, required this.userData});

  @override
  State<LocationSettings> createState() => _LocationSettingsState();
}

class _LocationSettingsState extends State<LocationSettings> {
  final UserRepository _userRepository = UserRepository();

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

    try {
      // 위치 권한 요청
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationAddress = '위치 권한이 거부되었습니다.';
          _isLoading = false;
        });
        return;
      }

      // 현재 위치 가져오기
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 좌표를 주소로 변환
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _locationAddress =
              '${place.locality}, ${place.administrativeArea}, ${place.country}';
          _isButtonEnabled = true; // 위치 정보가 유효하면 버튼 활성화
        });
      } else {
        setState(() {
          _locationAddress = '주소를 찾을 수 없습니다.';
          _isButtonEnabled = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationAddress = '위치 정보를 가져오는 중 오류 발생: $e';
        _isButtonEnabled = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('location_settings_page')));
  }
}
