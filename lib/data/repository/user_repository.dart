import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _currentUserIdKey = 'current_user_id';

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

  // 현재 사용자를 제외한 닉네임 중복 검사
  Future<bool> checkNicknameExistsExcludingCurrentUser(
    String nickname,
    String currentUserId,
  ) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .get();

      for (var doc in result.docs) {
        if (doc.data()['userId'] != currentUserId) {
          return true; // 다른 사용자가 해당 닉네임을 사용 중
        }
      }
      return false; // 중복 없음
    } catch (e) {
      debugPrint('닉네임 중복 체크 실패: ${e.toString()}');
      return false;
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

  Future<List<User>> getUsersByAddress(String address, String userId) async {
    try {
      final useraddress = await _firestore
          .collection('users')
          .where('address', isEqualTo: address)
          .get();

      final users = useraddress.docs
          .map((doc) => User.fromJson(doc.data()))
          .where((user) => user.userId != userId) // 현재 사용자 제외
          .toList();

      return users;
    } catch (e) {
      debugPrint('주소 기반 사용자 목록 조회 실패: $e');
      return []; // 오류 발생 시 빈 리스트 반환
  // 사용자 정보 업데이트
  Future<bool> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.userId).update({
        'nickname': user.nickname,
        'introduction': user.introduction,
        'imageUrl': user.imageUrl,
        // location과 address는 별도 메서드에서 관리하므로 제외
      });
      return true;
    } catch (e) {
      debugPrint('사용자 정보 업데이트 실패: ${e.toString()}');
      return false;
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

  // 현재 로그인한 사용자의 전체 정보 가져오기
  Future<User?> getCurrentUser() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return null;

      return await getUserById(userId);
    } catch (e) {
      debugPrint('현재 사용자 정보 조회 실패: ${e.toString()}');
      return null;
    }
  }

  // 로그인 시 사용자 ID를 기기에 저장
  Future<void> setCurrentUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserIdKey, userId);
      debugPrint('사용자 ID 저장 완료: $userId');
    } catch (e) {
      debugPrint('사용자 ID 저장 실패: ${e.toString()}');
    }
  }

  // 기기에 저장된 현재 사용자 ID 가져오기
  Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_currentUserIdKey);
      debugPrint('저장된 사용자 ID: $userId');
      return userId;
    } catch (e) {
      debugPrint('사용자 ID 조회 실패: ${e.toString()}');
      return null;
    }
  }

  // 로그아웃 (기기에 저장된 사용자 정보 삭제)
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserIdKey);
      debugPrint('로그아웃 완료');
    } catch (e) {
      debugPrint('로그아웃 실패: ${e.toString()}');
    }
  }
}
