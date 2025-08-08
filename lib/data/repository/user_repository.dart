import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gps_chat_app/data/model/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> addUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.userId).set(user.toJson());
      return true; // 성공적으로 추가되면 true 반환
    } catch (e) {
      print(e);
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
      print(e);
      return false; // 오류 발생 시 false 반환
    }
  }

  // Future<User?> getUserById(String userId) async {
  //   try {
  //     final docSnapshot = await _firestore.collection('users').doc(userId).get();
  //     if (docSnapshot.exists) {
  //       return User.fromJson(docSnapshot.data()!);
  //     }
  //     return null; // 유저가 존재하지 않으면 null 반환
  //   } catch (e) {
  //     debugPrint(e);
  //     return null; // 오류 발생 시 null 반환
  //   }
  // }

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
      print(e);
      return null; // 오류 발생 시 null 반환
    }
  }
}
