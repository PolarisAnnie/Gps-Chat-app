// import 'package:cloud_firestore/cloud_firestore.dart';

// // 사용자 모델 클래스
// class User {
//   // 기본 정보
//   final String userId; // 유저 아이디
//   final String nickname; // 닉네임
//   final String introduction; // 소개
//   final String imagePath; // 프로필사진 경로

//   // 위치 정보
//   final GeoPoint location; // 위도, 경도 (Firebase GeoPoint)
//   final String address; // 읽기 쉬운 주소

//   User({
//     required this.userId,
//     required this.nickname,
//     required this.introduction,
//     required this.imagePath,
//     required this.location,
//     required this.address,
//   });

//   // Firestore에서 불러올 때 사용
//   User.fromJson(Map<String, dynamic> map)
//     : this(
//         userId: map['userId'],
//         nickname: map['nickname'],
//         introduction: map['introduction'],
//         imagePath: map['imagePath'],
//         location: map['location'],
//         address: map['address'] ?? '',
//       );

//   // Firestore로 저장할 때 사용
//   Map<String, dynamic> toJson() {
//     return {
//       'userId': userId,
//       'nickname': nickname,
//       'introduction': introduction,
//       'imagePath': imagePath,
//       'location': location,
//       'address': address,
//     };
//   }
// }
