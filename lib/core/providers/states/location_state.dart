import 'package:geolocator/geolocator.dart';

class LocationState {
  final bool isLoading;
  final String address;
  final Position? currentPosition;
  final bool isButtonEnabled;
  final String? errorMessage;

  const LocationState({
    this.isLoading = false,
    this.address = '위치 정보를 가져와주세요.',
    this.currentPosition,
    this.isButtonEnabled = false,
    this.errorMessage,
  });

  LocationState copyWith({
    bool? isLoading,
    String? address,
    Position? currentPosition,
    bool? isButtonEnabled,
    String? errorMessage,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      address: address ?? this.address,
      currentPosition: currentPosition ?? this.currentPosition,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
