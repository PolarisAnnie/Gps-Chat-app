import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';

// UserRepository를 제공하는 Provider
// (UserRepository가 다른 곳에서 사용될 수 있으므로 분리)
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// 현재 로그인된 유저의 정보를 제공하는 Provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  // 위에서 만든 userRepositoryProvider를 읽어와 사용
  final userRepository = ref.watch(userRepositoryProvider);
  return await userRepository.getCurrentUser();
});

// 주변 유저 목록을 제공하는 Provider
final nearbyUsersProvider = FutureProvider<List<User>>((ref) async {
  final userRepository = ref.watch(userRepositoryProvider);
  // currentUserProvider가 완료될 때까지 기다렸다가 그 결과를 사용
  final currentUser = await ref.watch(currentUserProvider.future);

  // 현재 유저 정보나 주소가 없으면 빈 리스트 반환
  if (currentUser?.address == null || currentUser?.userId == null) {
    return [];
  }

  // UserRepository를 통해 같은 주소의 다른 유저 목록을 가져옴
  return userRepository.getUsersByAddress(
    currentUser!.address!,
    currentUser.userId,
  );
});
