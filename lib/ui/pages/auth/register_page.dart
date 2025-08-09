import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/storage_repository.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  final String nickname;
  const RegisterPage({super.key, required this.nickname});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // firebase repository 인스턴스
  final UserRepository _userRepository = UserRepository();
  final StorageRepository _storageRepository = StorageRepository();

  // 컨트롤러를 사용해서 닉네임과 소개글을 관리
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _introController = TextEditingController();

  XFile? _profileImage;
  bool _isButtonEnabled = false;
  bool _isLoading = false; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();

    // 이전 화면에서 받은 닉네임을 컨트롤러에 설정
    _nicknameController.text = widget.nickname;
    _nicknameController.addListener(_validateForm);
    _introController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _introController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // 폼 유효성 검사 로직
      // 예: 닉네임이 비어있지 않은지, 소개글이 비어있지 않은지 확인
      final isNicknameValid = _nicknameController.text.length >= 4;
      final isIntroValid = _introController.text.isNotEmpty;
      final isImageValid = _profileImage != null;
      _isButtonEnabled = isNicknameValid && isIntroValid && isImageValid;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
      _validateForm(); // 이미지 선택 후 폼 유효성 검사
    }
  }

  void _onNextPressed() async {
    if (!_isButtonEnabled) return;

    setState(() {
      _isLoading = true; // 로딩 시작
    });

    try {
      // 1. Firestore에서 미리 고유한 userId를 생성
      final userId = FirebaseFirestore.instance.collection('users').doc().id;
      // 2. 프로필 이미지를 Firebase Storage에 업로드
      String? imageUrl = await _storageRepository.uploadProfileImage(
        filePath: _profileImage!.path, // 선택한 이미지의 로컬 경로
        userId: userId,
      );
      // 3. 이미지 업로드 실패 시, 사용자에게 알리고 함수 종료
      if (imageUrl == null) {
        // throw Exception('프로필 이미지 업로드에 실패했습니다.');
        imageUrl = 'https://picsum.photos/200/300';
      }
      // 4. User 객체 생성 (위치정보는 아직 없음)

      final newUser = User(
        userId: userId,
        nickname: _nicknameController.text,
        introduction: _introController.text,
        imageUrl: imageUrl,
        // 위치 정보는 다음페이지에서 업데이트될것임
        location: GeoPoint(0, 0),
        address: '',
      );

      // 5. UserRepository를 사용하여 Firestore에 사용자 정보 추가
      final bool isSuccess = await _userRepository.addUser(newUser);

      if (isSuccess) {
        // 다음 단계로 이동
        Navigator.pushNamed(context, '/location', arguments: newUser);
      } else {
        throw Exception('사용자 정보 저장에 실패했습니다.');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text('회원가입')),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // 프로필 이미지 선택
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: _profileImage != null
                                    ? FileImage(File(_profileImage!.path))
                                    : null,
                                child: _profileImage == null
                                    ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppTheme.textTertiary,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: AppTheme.textOnPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      // 닉네임 입력
                      TextField(
                        controller: _nicknameController,
                        decoration: InputDecoration(
                          labelText: '닉네임',
                          labelStyle: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          hintText: '사용할 이름을 입력해주세요',
                          hintStyle: TextStyle(color: AppTheme.textTertiary),
                          border: UnderlineInputBorder(),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        child: Text(
                          '소개',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // 소개글 입력
                      TextField(
                        controller: _introController,
                        decoration: InputDecoration(
                          hintText: '가볍게 나에 대한 소개를 작성해주세요',
                          hintStyle: TextStyle(color: AppTheme.textTertiary),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
                // 다음 단계로 이동 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled && !_isLoading
                        ? _onNextPressed
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.textOnPrimary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppTheme.textOnPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            '다음 단계로',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
