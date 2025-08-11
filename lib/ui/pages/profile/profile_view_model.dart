import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';

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
  final auth.FirebaseAuth _auth;

  ProfileViewModel(this._userRepository, this._auth)
    : super(const ProfileState()) {
    loadUserData();
  }

  Future<void> loadUserData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authUser = _auth.currentUser;
      User? userData;

      if (authUser != null) {
        userData = await _userRepository.getUserById(authUser.uid);
        userData ??= User(
          userId: authUser.uid,
          nickname: authUser.displayName ?? '사용자',
          introduction: 'Flutter를 공부중',
          imageUrl: authUser.photoURL ?? '',
          location: const GeoPoint(37.5665, 126.9780),
          address: '서울시 중구',
        );
      } else {
        userData = User(
          userId: 'test_user_1',
          nickname: '올리브영털털이',
          introduction: '안녕하세요 저는 flutter를 배우고 있습니다',
          imageUrl: '',
          location: const GeoPoint(37.5665, 126.9780),
          address: '서울시 중구',
        );
      }

      state = state.copyWith(user: userData, isLoading: false);
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

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider 정의
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);
final firebaseAuthProvider = Provider<auth.FirebaseAuth>(
  (ref) => auth.FirebaseAuth.instance,
);

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
      final userRepository = ref.watch(userRepositoryProvider);
      final firebaseAuth = ref.watch(firebaseAuthProvider);
      return ProfileViewModel(userRepository, firebaseAuth);
    });
