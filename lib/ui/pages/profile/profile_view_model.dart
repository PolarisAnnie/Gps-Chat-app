import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';
import 'package:gps_chat_app/data/repository/storage_repository.dart';

// 프로필 상태 클래스
class ProfileState {
  final User? user;
  final bool isLoading;
  final bool isEditing;
  final bool isSaving;
  final String? error;
  final String? nicknameError;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.isEditing = false,
    this.isSaving = false,
    this.error,
    this.nicknameError,
  });

  ProfileState copyWith({
    User? user,
    bool? isLoading,
    bool? isEditing,
    bool? isSaving,
    String? error,
    String? nicknameError,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
      nicknameError: nicknameError ?? this.nicknameError,
    );
  }
}

// ProfileViewModel
class ProfileViewModel extends StateNotifier<ProfileState> {
  final UserRepository _userRepository;
  final StorageRepository _storageRepository;

  ProfileViewModel(this._userRepository, this._storageRepository)
    : super(const ProfileState()) {
    loadUserData();
  }

  Future<void> loadUserData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // getCurrentUser 메서드로 실제 Firebase 사용자 데이터 가져오기
      final userData = await _userRepository.getCurrentUser();

      if (userData != null) {
        state = state.copyWith(user: userData, isLoading: false);
      } else {
        // 로그인된 사용자가 없는 경우 에러 처리
        state = state.copyWith(
          isLoading: false,
          error: '로그인된 사용자를 찾을 수 없습니다. 다시 로그인해주세요.',
        );
      }
    } catch (e) {
      debugPrint('사용자 데이터 로드 실패: $e');
      state = state.copyWith(isLoading: false, error: '데이터를 불러오는데 실패했습니다.');
    }
  }

  void startEditing() {
    state = state.copyWith(isEditing: true, nicknameError: null);
  }

  void cancelEditing() {
    state = state.copyWith(isEditing: false, nicknameError: null);
  }

  Future<bool> saveProfile(String nickname, String introduction) async {
    final currentUser = state.user;
    if (currentUser == null || state.isSaving) return false;

    state = state.copyWith(isSaving: true, nicknameError: null);

    try {
      // 유효성 검사
      if (nickname.trim().isEmpty) {
        state = state.copyWith(isSaving: false, nicknameError: '닉네임을 입력해주세요.');
        return false;
      }

      if (nickname.trim().length < 2) {
        state = state.copyWith(
          isSaving: false,
          nicknameError: '닉네임은 2글자 이상이어야 합니다.',
        );
        return false;
      }

      if (nickname.trim().length > 20) {
        state = state.copyWith(
          isSaving: false,
          nicknameError: '닉네임은 20글자 이하여야 합니다.',
        );
        return false;
      }

      if (introduction.length > 100) {
        state = state.copyWith(isSaving: false, error: '소개글은 100자 이내로 작성해주세요.');
        return false;
      }

      // 닉네임 중복 검사
      if (nickname.trim() != currentUser.nickname) {
        final isDuplicate = await _userRepository
            .checkNicknameExistsExcludingCurrentUser(
              nickname.trim(),
              currentUser.userId,
            );
        if (isDuplicate) {
          state = state.copyWith(
            isSaving: false,
            nicknameError: '이미 사용 중인 닉네임입니다.',
          );
          return false;
        }
      }

      // 변경사항 확인
      if (nickname.trim() == currentUser.nickname &&
          introduction.trim() == currentUser.introduction) {
        state = state.copyWith(isEditing: false, isSaving: false);
        return true;
      }

      // Firebase 업데이트
      final updatedUser = User(
        userId: currentUser.userId,
        nickname: nickname.trim(),
        introduction: introduction.trim(),
        imageUrl: currentUser.imageUrl,
        location: currentUser.location,
        address: currentUser.address,
      );

      await Future.delayed(const Duration(milliseconds: 500)); // UX를 위한 지연
      final success = await _userRepository.updateUser(updatedUser);

      if (success) {
        state = state.copyWith(
          user: updatedUser,
          isEditing: false,
          isSaving: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          error: '저장에 실패했습니다. 다시 시도해주세요.',
        );
        return false;
      }
    } catch (e) {
      debugPrint('프로필 저장 오류: $e');
      state = state.copyWith(isSaving: false, error: '저장 중 오류가 발생했습니다.');
      return false;
    }
  }

  // 프로필 이미지 업데이트 기능
  Future<bool> updateProfileImage(File imageFile) async {
    final currentUser = state.user;
    if (currentUser == null || state.isSaving) return false;

    state = state.copyWith(isSaving: true);

    try {
      // 이미지 업로드
      final imageUrl = await _storageRepository.uploadProfileImage(
        filePath: imageFile.path,
        userId: currentUser.userId,
      );

      if (imageUrl == null) {
        state = state.copyWith(
          isSaving: false,
          error: '이미지 업로드에 실패했습니다. 다시 시도해주세요.',
        );
        return false;
      }

      // Firebase 사용자 정보 업데이트
      final updatedUser = currentUser.copyWith(imageUrl: imageUrl);

      final success = await _userRepository.updateUser(updatedUser);

      if (success) {
        state = state.copyWith(user: updatedUser, isSaving: false);
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          error: '이미지 업데이트에 실패했습니다. 다시 시도해주세요.',
        );
        return false;
      }
    } catch (e) {
      debugPrint('프로필 이미지 업데이트 오류: $e');
      state = state.copyWith(isSaving: false, error: '이미지 업데이트 중 오류가 발생했습니다.');
      return false;
    }
  }

  // 이미지 선택 기능
  Future<void> pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final success = await updateProfileImage(File(pickedFile.path));
        if (success) {
          // 성공 메시지는 UI에서 처리하기 위해 상태에 저장
          state = state.copyWith(error: 'IMAGE_UPDATE_SUCCESS');
        }
      }
    } catch (e) {
      state = state.copyWith(error: '이미지를 선택할 수 없습니다.');
    }
  }

  // 로그아웃 기능
  Future<bool> logout() async {
    try {
      await _userRepository.logout();
      // 상태를 완전히 초기화 (user를 null로 설정)
      state = const ProfileState(user: null, isLoading: false);
      return true;
    } catch (e) {
      debugPrint('로그아웃 실패: $e');
      state = state.copyWith(error: '로그아웃에 실패했습니다.');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider 정의
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

final storageRepositoryProvider = Provider<StorageRepository>(
  (ref) => StorageRepository(),
);

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
      final userRepository = ref.watch(userRepositoryProvider);
      final storageRepository = ref.watch(storageRepositoryProvider);
      return ProfileViewModel(userRepository, storageRepository);
    });
