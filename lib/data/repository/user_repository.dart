import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gps_chat_app/data/model/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> addUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.userId).set(user.toJson());
      return true; // 성공적으로 추가되면 true 반환
    } catch (e) {
      debugPrint('사용자 추가 실패: ${e.toString()}');
      return false; // 오류 발생 시 false 반환
    }
  }

  Future<bool> checkNicknameExists(String nickname) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .limit(1) // 닉네임은 유일해야 하므로 limit 1
          .get();

      return result.docs.isNotEmpty; // 닉네임이 존재하면 true, 아니면 false
    } catch (e) {
      debugPrint('닉네임 중복 체크 실패: ${e.toString()}');
      return false; // 오류 발생 시 false 반환
    }
  }

  Future<User?> getUserById(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      if (docSnapshot.exists) {
        return User.fromJson(docSnapshot.data()!);
      }
      return null; // 유저가 존재하지 않으면 null 반환
    } catch (e) {
      debugPrint('사용자 정보 가져오기 실패: ${e.toString()}');
      return null; // 오류 발생 시 null 반환
    }
  }

  Future<User?> getUserByNickname(String nickname) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .limit(1) // 닉네임은 유일해야 하므로 limit 1
          .get();

      if (result.docs.isNotEmpty) {
        return User.fromJson(result.docs.first.data());
      }
      return null; // 유저가 존재하지 않으면 null 반환
    } catch (e) {
      debugPrint('닉네임으로 사용자 조회 실패: ${e.toString()}');
      return null; // 오류 발생 시 null 반환
    }
  }

  Future<bool> updateUserLocation({
    required String userId,
    required GeoPoint location,
    String? address,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'location': location,
        'address': address,
      });
      return true; // 성공적으로 업데이트되면 true 반환
    } catch (e) {
      debugPrint('위치 정보 업데이트 실패: ${e.toString()}');
      return false; // 오류 발생 시 false 반환
    }
  }

  // 프로필 페이지용: 사용자 정보 업데이트
  Future<bool> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.userId).update({
        'nickname': user.nickname,
        'introduction': user.introduction,
        'imageUrl': user.imageUrl,
      });
      return true;
    } catch (e) {
      debugPrint('사용자 정보 업데이트 실패: ${e.toString()}');
      return false;
    }
  }

  // 프로필 페이지용: 닉네임 중복 체크 (현재 사용자 제외)
  Future<bool> checkNicknameExistsExcludingCurrentUser(
    String nickname,
    String currentUserId,
  ) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .get();

      // 현재 사용자가 아닌 다른 사용자가 같은 닉네임을 사용하는지 확인
      for (var doc in result.docs) {
        if (doc.data()['userId'] != currentUserId) {
          return true; // 다른 사용자가 같은 닉네임 사용 중
        }
      }
      return false; // 중복 없음
    } catch (e) {
      debugPrint('닉네임 중복 체크 실패: ${e.toString()}');
      return false;
    }
  }
}
