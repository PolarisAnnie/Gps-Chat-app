import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 이미지 업로드 (파일)
  static Future<String?> uploadImageFile({
    required File file,
    required String path,
    String? fileName,
  }) async {
    try {
      final String uploadFileName =
          fileName ?? DateTime.now().millisecondsSinceEpoch.toString();
      final Reference ref = _storage.ref().child('$path/$uploadFileName');

      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Storage 업로드 실패: $e');
      }
      return null;
    }
  }

  /// 이미지 업로드 (바이트 데이터)
  static Future<String?> uploadImageData({
    required Uint8List data,
    required String path,
    String? fileName,
    String? contentType,
  }) async {
    try {
      final String uploadFileName =
          fileName ?? DateTime.now().millisecondsSinceEpoch.toString();
      final Reference ref = _storage.ref().child('$path/$uploadFileName');

      final SettableMetadata metadata = SettableMetadata(
        contentType: contentType ?? 'image/jpeg',
      );

      final UploadTask uploadTask = ref.putData(data, metadata);
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Storage 업로드 실패: $e');
      }
      return null;
    }
  }

  /// 이미지 삭제
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Storage 삭제 실패: $e');
      }
      return false;
    }
  }

  /// 폴더 내 모든 파일 목록 가져오기
  static Future<List<String>> getImagesFromFolder(String folderPath) async {
    try {
      final Reference ref = _storage.ref().child(folderPath);
      final ListResult result = await ref.listAll();

      List<String> imageUrls = [];
      for (Reference fileRef in result.items) {
        final String downloadUrl = await fileRef.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      return imageUrls;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Storage 폴더 목록 가져오기 실패: $e');
      }
      return [];
    }
  }

  /// 특정 경로의 파일 다운로드 URL 가져오기
  static Future<String?> getDownloadUrl(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Storage 다운로드 URL 가져오기 실패: $e');
      }
      return null;
    }
  }

  /// 업로드 진행률을 스트림으로 반환
  static Stream<double> uploadWithProgress({
    required File file,
    required String path,
    String? fileName,
  }) {
    final String uploadFileName =
        fileName ?? DateTime.now().millisecondsSinceEpoch.toString();
    final Reference ref = _storage.ref().child('$path/$uploadFileName');
    final UploadTask uploadTask = ref.putFile(file);

    return uploadTask.snapshotEvents.map((TaskSnapshot snapshot) {
      return snapshot.bytesTransferred / snapshot.totalBytes;
    });
  }
}
