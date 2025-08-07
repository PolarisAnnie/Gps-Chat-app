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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Center(child: Text('Welcome ${widget.nickname}')),
    );
  }
}
