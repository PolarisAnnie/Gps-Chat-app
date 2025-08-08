import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  final String nickname;
  const RegisterPage({super.key, required this.nickname});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _introController = TextEditingController();

  XFile? _profileImage;
  bool _isButtonEnabled = false;

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

  void _onNextPressed() {
    if (!_isButtonEnabled) return;

    // 데이터 가지고
    final userData = {
      'nickname': _nicknameController.text,
      'introduction': _introController.text,
      'profile_image': _profileImage?.path,
    };

    // 다음 단계로 이동
    Navigator.pushNamed(context, '/location', arguments: userData);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('회원가입', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Column(
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
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // 닉네임 입력
                  TextField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: '닉네임',
                      hintText: '사용할 이름을 입력해주세요',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  // 소개글 입력
                  TextField(
                    controller: _introController,
                    decoration: InputDecoration(
                      labelText: '소개',
                      hintText: '가볍게 나에 대한 소개를 작성해주세요',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
