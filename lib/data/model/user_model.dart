//User
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  // 기본 정보
  final String userId; //유저 아이디
  final String nickname; //닉네임
  final String introduction; //소개
  final String imageUrl; //프로필사진

  // 위치 정보
  final GeoPoint location; // 위치 정보 (GeoPoint 사용)
  final String? address; // 읽기 쉬운 주소

  double get distance => _distance;
  set distance(double value) {
    _distance = value;
  }

  double _distance = 0.0;

  User({
    required this.userId,
    required this.nickname,
    required this.introduction,
    required this.imageUrl,
    required this.location,
    this.address,
  });

  // Firestore에서 불러올 때 사용
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? '',
      nickname: json['nickname'] ?? '닉네임 없음',
      introduction: json['introduction'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      location: json['location'] as GeoPoint? ?? GeoPoint(0, 0),
      address: json['address'],
    );
  }

  get id => null;

  // Firestore로 저장할 때 사용
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'introduction': introduction,
      'imageUrl': imageUrl,
      'location': location,
      'address': address,
    };
  }
}
