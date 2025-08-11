import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gps_chat_app/core/providers/models/register_state.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';
import 'package:gps_chat_app/data/repository/storage_repository.dart';
import 'package:gps_chat_app/data/model/user_model.dart';

class RegisterViewModel extends StateNotifier<RegisterState> {
  final UserRepository _userRepository;
  final StorageRepository _storageRepository;

  RegisterViewModel(this._userRepository, this._storageRepository)
    : super(const RegisterState());

  void setNickname(String nickname) {
    final newState = state.copyWith(nickname: nickname);
    state = newState.copyWith(isFormValid: _validateForm(newState));
  }

  void setIntroduction(String introduction) {
    final newState = state.copyWith(introduction: introduction);
    state = newState.copyWith(isFormValid: _validateForm(newState));
  }

  void setProfileImage(File? image) {
    final newState = state.copyWith(profileImage: image);
    state = newState.copyWith(isFormValid: _validateForm(newState));
  }

<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> dev
  /// 작성중인 데이터를 모두 초기화
  void clearData() {
    state = const RegisterState();
  }

<<<<<<< HEAD
>>>>>>> dev
=======
>>>>>>> dev
  bool _validateForm(RegisterState state) {
    final isNicknameValid = state.nickname.length >= 4;
    final isIntroValid = state.introduction.isNotEmpty;
    final isImageValid = state.profileImage != null;
    return isNicknameValid && isIntroValid && isImageValid;
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setProfileImage(File(pickedFile.path));
      }
    } catch (e) {
      state = state.copyWith(errorMessage: '이미지를 선택할 수 없습니다.');
    }
  }

  Future<User?> registerUser() async {
    if (!state.isFormValid) return null;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. 사용자 ID 생성
      final userId = DateTime.now().millisecondsSinceEpoch.toString();

      // 2. 이미지 업로드
      String? imageUrl;
      if (state.profileImage != null) {
        imageUrl = await _storageRepository.uploadProfileImage(
          filePath: state.profileImage!.path,
          userId: userId,
        );
      }

      if (imageUrl == null) {
        throw Exception('프로필 이미지 업로드에 실패했습니다.');
      }

      // 3. User 객체 생성
      final newUser = User(
        userId: userId,
        nickname: state.nickname,
        introduction: state.introduction,
        imageUrl: imageUrl,
        location: GeoPoint(0, 0),
        address: '',
      );

      // 4. 사용자 정보 저장
      final isSuccess = await _userRepository.addUser(newUser);

      if (isSuccess) {
        state = state.copyWith(isLoading: false);
        return newUser;
      } else {
        throw Exception('사용자 정보 저장에 실패했습니다.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }
}

final registerViewModelProvider =
    StateNotifierProvider<RegisterViewModel, RegisterState>((ref) {
      return RegisterViewModel(UserRepository(), StorageRepository());
    });
