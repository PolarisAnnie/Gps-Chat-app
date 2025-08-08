//User
class User {
  // 기본 정보
  final int userId; //유저 아이디
  final String nickname; //닉네임
  final String introduction; //소개
  final String imageUrl; //프로필사진

  // 위치 정보
  final double latitude; // 위도
  final double longitude; // 경도
  final String? address; // 읽기 쉬운 주소(선택적)

  User({
    required this.userId,
    required this.nickname,
    required this.introduction,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  // Firestore에서 불러올 때 사용
  User.fromJson(Map<String, dynamic> map)
    : this(
        userId: map['userId'],
        nickname: map['nickname'],
        introduction: map['introduction'],
        imageUrl: map['imageUrl'],
        latitude: map['latitude'],
        longitude: map['longitude'],
        address: map['address'] ?? '',
      );

  // Firestore로 저장할 때 사용
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'introduction': introduction,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
