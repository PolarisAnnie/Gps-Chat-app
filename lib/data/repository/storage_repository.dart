// 이미지 업로드를 전담하는 리포지토리입니다!

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 프로필 이미지를 firebase storage에 업로드하고, 다운로드 URL을 반환합니다.
  Future<String?> uploadProfileImage({
    required String filePath,
    required String userId,
  }) async {
    try {
      // Storage에 저장될 파일 reference 생성 (예: 'profile_images/userId.jpg')
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');

      // 파일 업로드
      final uploadTask = await ref.putFile(File(filePath));

      // 업로드 완료 후 다운로드 URL 가져오기
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl; // 다운로드 URL 반환
    } catch (e) {
      print('StorageRepository: 이미지 업로드 실패 - $e');
      return null; // 오류 발생 시 null 반환
    }
  }
}
