import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserRepository _userRepository = UserRepository();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();

  User? _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _nicknameError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Firebase Auth에서 현재 로그인된 사용자 확인
      final authUser = _auth.currentUser;

      if (authUser != null) {
        // 로그인된 사용자가 있는 경우, Firestore에서 사용자 정보 가져오기
        final userData = await _userRepository.getUserById(authUser.uid);

        if (userData != null && mounted) {
          setState(() {
            _currentUser = userData;
            _nicknameController.text = userData.nickname;
            _introductionController.text = userData.introduction;
          });
        } else if (mounted) {
          // Firestore에 사용자 정보가 없는 경우, 기본 정보로 설정
          final defaultUser = User(
            userId: authUser.uid,
            nickname: authUser.displayName ?? '사용자',
            introduction: 'Flutter를 공부중',
            imageUrl: authUser.photoURL ?? '',
            location: const GeoPoint(37.5665, 126.9780),
            address: '서울시 중구',
          );

          setState(() {
            _currentUser = defaultUser;
            _nicknameController.text = defaultUser.nickname;
            _introductionController.text = defaultUser.introduction;
          });
        }
      } else {
        // 로그인되지 않은 경우, 테스트용 데이터 사용
        if (mounted) {
          final testUser = User(
            userId: 'test_user_1',
            nickname: '올리브영털털이',
            introduction: '안녕하세요 저는 flutter를 배우고 있습니다',
            imageUrl: '',
            location: const GeoPoint(37.5665, 126.9780),
            address: '서울시 중구',
          );

          setState(() {
            _currentUser = testUser;
            _nicknameController.text = testUser.nickname;
            _introductionController.text = testUser.introduction;
          });
        }
      }
    } catch (e) {
      debugPrint('사용자 데이터 로드 실패: $e');
      if (mounted) {
        // 네트워크 오류 또는 Firebase 오류 시 재시도 옵션 제공
        _showRetryDialog();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _nicknameError = null;
    });
  }

  void _cancelEditing() {
    final currentUser = _currentUser;
    setState(() {
      _isEditing = false;
      _nicknameError = null;
      _nicknameController.text = currentUser?.nickname ?? '';
      _introductionController.text = currentUser?.introduction ?? '';
    });
  }

  Future<void> _saveProfile() async {
    final currentUser = _currentUser;
    if (currentUser == null) return;

    // 이미 저장 중인 경우 중복 실행 방지
    if (_isSaving) return;

    setState(() => _isSaving = true);

    // 로딩 스낵바 표시
    _showLoadingSnackBar('프로필을 저장하고 있습니다...');

    try {
      // 닉네임 유효성 검사
      final nickname = _nicknameController.text.trim();
      if (nickname.isEmpty) {
        setState(() {
          _nicknameError = '닉네임을 입력해주세요.';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
        }
        return;
      }

      if (nickname.length < 2) {
        setState(() {
          _nicknameError = '닉네임은 2글자 이상이어야 합니다.';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
        }
        return;
      }

      if (nickname.length > 20) {
        setState(() {
          _nicknameError = '닉네임은 20글자 이하여야 합니다.';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
        }
        return;
      }

      // 소개글 길이 검사
      final introduction = _introductionController.text.trim();
      if (introduction.length > 100) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
        }
        _showErrorSnackBar('소개글은 100자 이내로 작성해주세요.');
        return;
      }

      // 닉네임 중복 검사 (현재 사용자 제외)
      if (nickname != currentUser.nickname) {
        final isDuplicate = await _userRepository
            .checkNicknameExistsExcludingCurrentUser(
              nickname,
              currentUser.userId,
            );
        if (isDuplicate) {
          setState(() {
            _nicknameError = '이미 사용 중인 닉네임입니다.';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
          }
          return;
        }
      }

      // 변경사항이 있는지 확인
      if (nickname == currentUser.nickname &&
          introduction == currentUser.introduction) {
        setState(() {
          _isEditing = false;
          _nicknameError = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          _showSuccessMessage();
        }
        return;
      }

      // Firebase 업데이트
      final updatedUser = User(
        userId: currentUser.userId,
        nickname: nickname,
        introduction: introduction,
        imageUrl: currentUser.imageUrl,
        location: currentUser.location,
        address: currentUser.address,
      );

      // 약간의 지연을 추가하여 사용자가 로딩을 인지할 수 있도록 함
      await Future.delayed(const Duration(milliseconds: 500));

      final success = await _userRepository.updateUser(updatedUser);

      if (success) {
        if (mounted) {
          setState(() {
            _currentUser = updatedUser;
            _isEditing = false;
            _nicknameError = null;
          });
          ScaffoldMessenger.of(context).clearSnackBars();
          _showSuccessMessage();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          _showErrorSnackBar('저장에 실패했습니다. 네트워크를 확인하고 다시 시도해주세요.');
        }
      }
    } catch (e) {
      debugPrint('프로필 저장 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        _showErrorSnackBar('저장 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).clearSnackBars(); // 기존 스낵바 제거
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppTheme.primaryColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '수정이 완료되었습니다.',
                style: TextStyle(
                  fontFamily: 'Paperlogy',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        action: SnackBarAction(
          label: '',
          onPressed: () {},
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars(); // 기존 스낵바 제거
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Paperlogy',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
      ),
    );
  }

  void _showLoadingSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Paperlogy',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.textSecondary,
        duration: const Duration(seconds: 30), // 긴 시간 설정 (수동으로 제거)
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
      ),
    );
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '데이터 로드 실패',
            style: TextStyle(
              fontFamily: 'Paperlogy',
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          content: const Text(
            '사용자 정보를 불러오는데 실패했습니다.\n네트워크 연결을 확인하고 다시 시도해주세요.',
            style: TextStyle(
              fontFamily: 'Paperlogy',
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 테스트용 데이터로 계속 진행
                final testUser = User(
                  userId: 'test_user_1',
                  nickname: '올리브영털털이',
                  introduction: '안녕하세요 저는 flutter를 배우고 있습니다',
                  imageUrl: '',
                  location: const GeoPoint(37.5665, 126.9780),
                  address: '서울시 중구',
                );

                setState(() {
                  _currentUser = testUser;
                  _nicknameController.text = testUser.nickname;
                  _introductionController.text = testUser.introduction;
                });
              },
              child: const Text(
                '오프라인으로 계속',
                style: TextStyle(
                  fontFamily: 'Paperlogy',
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadUserData(); // 재시도
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '다시 시도',
                style: TextStyle(
                  fontFamily: 'Paperlogy',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '프로필',
          style: TextStyle(
            fontFamily: 'Paperlogy',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '프로필 정보를 불러오는 중...',
                          style: TextStyle(
                            fontFamily: 'Paperlogy',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '잠시만 기다려주세요',
                          style: TextStyle(
                            fontFamily: 'Paperlogy',
                            fontSize: 14,
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : _currentUser == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 64,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '사용자 정보를 찾을 수 없습니다',
                          style: TextStyle(
                            fontFamily: 'Paperlogy',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '네트워크 연결을 확인해주세요',
                          style: TextStyle(
                            fontFamily: 'Paperlogy',
                            fontSize: 14,
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '다시 시도',
                            style: TextStyle(
                              fontFamily: 'Paperlogy',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return const Center(
        child: Text(
          '사용자 정보를 찾을 수 없습니다.',
          style: TextStyle(
            fontFamily: 'Paperlogy',
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // 프로필 카드
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // 프로필 이미지
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: currentUser.imageUrl.isNotEmpty
                        ? Image.network(
                            currentUser.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildDefaultProfileImage(),
                          )
                        : _buildDefaultProfileImage(),
                  ),
                ),
                const SizedBox(height: 16),
                // 닉네임
                Text(
                  currentUser.nickname,
                  style: const TextStyle(
                    fontFamily: 'Paperlogy',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // 소개글
                Text(
                  currentUser.introduction.isEmpty
                      ? 'Flutter를 공부중'
                      : currentUser.introduction,
                  style: const TextStyle(
                    fontFamily: 'Paperlogy',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          if (!_isEditing) ...[
            // 수정하기 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _startEditing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '수정하기',
                  style: TextStyle(
                    fontFamily: 'Paperlogy',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else ...[
            // 편집 모드
            _buildEditForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultProfileImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.person, size: 40, color: Colors.grey),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 닉네임 입력
        const Text(
          '닉네임',
          style: TextStyle(
            fontFamily: 'Paperlogy',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nicknameController,
          decoration: InputDecoration(
            hintText: '닉네임을 입력하세요',
            hintStyle: TextStyle(
              fontFamily: 'Paperlogy',
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.all(16),
            errorText: _nicknameError,
          ),
          style: const TextStyle(fontFamily: 'Paperlogy', fontSize: 16),
          maxLength: 20,
        ),

        const SizedBox(height: 16),

        // 소개 입력
        const Text(
          '소개',
          style: TextStyle(
            fontFamily: 'Paperlogy',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _introductionController,
          maxLines: 3,
          maxLength: 100,
          onChanged: (value) {
            // 실시간으로 글자 수 체크
            if (value.length > 100) {
              _introductionController.text = value.substring(0, 100);
              _introductionController.selection = TextSelection.fromPosition(
                TextPosition(offset: _introductionController.text.length),
              );
            }
          },
          decoration: InputDecoration(
            hintText: '자신을 소개해보세요',
            hintStyle: TextStyle(
              fontFamily: 'Paperlogy',
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: const TextStyle(
              fontFamily: 'Paperlogy',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          style: const TextStyle(fontFamily: 'Paperlogy', fontSize: 16),
        ),

        const SizedBox(height: 32),

        // 저장하기 버튼
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSaving ? Colors.grey : AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '저장하기',
                    style: TextStyle(
                      fontFamily: 'Paperlogy',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // 취소 버튼
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            onPressed: _cancelEditing,
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '취소',
              style: TextStyle(
                fontFamily: 'Paperlogy',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
