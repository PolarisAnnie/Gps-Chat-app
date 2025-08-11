import 'dart:io';
import 'dart:typed_data';
import '../../../core/services/firebase_storage_service.dart';

/// Storage Repository
/// ViewModel과 Firebase Storage Service 사이의 데이터 계층
/// Repository 패턴을 통해 서비스 계층을 추상화하고 비즈니스 로직을 분리
class StorageRepository {
  /// 프로필 이미지 업로드
  Future<String?> uploadProfileImage({
    required String filePath,
    required String userId,
  }) async {
    try {
      final file = File(filePath);
      return await FirebaseStorageService.uploadImageFile(
        file: file,
        path: 'profile_images',
        fileName: '$userId.jpg',
      );
    } catch (e) {
      return null;
    }
  }

  /// 채팅 이미지 업로드
  Future<String?> uploadChatImage({
    required File file,
    required String chatRoomId,
  }) async {
    try {
      return await FirebaseStorageService.uploadImageFile(
        file: file,
        path: 'chat_images/$chatRoomId',
      );
    } catch (e) {
      return null;
    }
  }

  /// 이미지 데이터 업로드 (Uint8List)
  Future<String?> uploadImageData({
    required Uint8List data,
    required String path,
    String? fileName,
    String? contentType,
  }) async {
    try {
      return await FirebaseStorageService.uploadImageData(
        data: data,
        path: path,
        fileName: fileName,
        contentType: contentType,
      );
    } catch (e) {
      return null;
    }
  }

  /// 이미지 삭제
  Future<bool> deleteImage(String imageUrl) async {
    try {
      return await FirebaseStorageService.deleteImage(imageUrl);
    } catch (e) {
      return false;
    }
  }

  /// 폴더 내 이미지 목록 가져오기
  Future<List<String>> getImagesFromFolder(String folderPath) async {
    try {
      return await FirebaseStorageService.getImagesFromFolder(folderPath);
    } catch (e) {
      return [];
    }
  }

  /// 업로드 진행률 스트림
  Stream<double> uploadWithProgress({
    required File file,
    required String path,
    String? fileName,
  }) {
    return FirebaseStorageService.uploadWithProgress(
      file: file,
      path: path,
      fileName: fileName,
    );
  }
}
