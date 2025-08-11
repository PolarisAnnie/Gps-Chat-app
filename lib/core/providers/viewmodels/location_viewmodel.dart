import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gps_chat_app/core/providers/models/location_state.dart';
import 'package:gps_chat_app/core/utils/location_utils.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';

class LocationViewModel extends StateNotifier<LocationState> {
  final UserRepository _userRepository;

  LocationViewModel(this._userRepository) : super(const LocationState());

  Future<void> fetchLocation() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final locationData = await LocationUtils.getCurrentLocationData();

      if (locationData != null) {
        state = state.copyWith(
          address: locationData.address,
          currentPosition: locationData.position,
          isButtonEnabled: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          address: '위치를 가져올 수 없습니다. 권한을 확인해주세요.',
          isButtonEnabled: false,
          isLoading: false,
          errorMessage: '위치 권한이 필요합니다.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '위치 정보를 가져오는 중 오류가 발생했습니다.',
      );
    }
  }

  Future<bool> updateUserLocation(String userId) async {
    if (state.currentPosition == null) return false;

    state = state.copyWith(isLoading: true);

    try {
      final newLocation = GeoPoint(
        state.currentPosition!.latitude,
        state.currentPosition!.longitude,
      );

      final isSuccess = await _userRepository.updateUserLocation(
        userId: userId,
        location: newLocation,
        address: state.address,
      );

      state = state.copyWith(isLoading: false);
      return isSuccess;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '위치 정보 업데이트 중 오류가 발생했습니다.',
      );
      return false;
    }
  }
}

final locationViewModelProvider =
    StateNotifierProvider<LocationViewModel, LocationState>((ref) {
      return LocationViewModel(UserRepository());
    });
