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
      userId: json['userId'],
      nickname: json['nickname'],
      introduction: json['introduction'],
      imageUrl: json['imageUrl'],
      location: json['location'] as GeoPoint,
      address: json['address'],
    );
  }

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

  // copyWith 메서드 추가
  User copyWith({
    String? userId,
    String? nickname,
    String? introduction,
    String? imageUrl,
    GeoPoint? location,
    String? address,
  }) {
    return User(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      introduction: introduction ?? this.introduction,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      address: address ?? this.address,
    );
  }
}
