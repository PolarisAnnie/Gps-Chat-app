import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';
import 'package:gps_chat_app/data/model/chat_message.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/chat_room_repository.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';

// 채팅방 목록 상태
class ChatRoomListState {
  final List<ChatRoom> chatRooms;
  final bool isLoading;

  ChatRoomListState({this.chatRooms = const [], this.isLoading = false});

  ChatRoomListState copyWith({List<ChatRoom>? chatRooms, bool? isLoading}) {
    return ChatRoomListState(
      chatRooms: chatRooms ?? this.chatRooms,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Repository 제공
final chatRoomRepositoryProvider = Provider<ChatRoomRepository>((ref) {
  return ChatRoomRepository();
});

final currentUserProvider = FutureProvider<User?>((ref) async {
  return await UserRepository().getCurrentUser();
});

// 채팅방 목록 비즈니스 로직
class ChatRoomListViewModel extends StateNotifier<ChatRoomListState> {
  final ChatRoomRepository _repository;
  final User? _currentUser; // 실제 사용자 정보

  ChatRoomListViewModel({
    required ChatRoomRepository repository,
    required User? currentUser, // 생성자에서 받기
  }) : _repository = repository,
       _currentUser = currentUser,
       super(ChatRoomListState());

  // 현재 사용자 정보 getter들
  String get currentUserId => _currentUser?.userId ?? "";
  String get currentAddress => _currentUser?.address ?? "";

  // 채팅방 목록 불러오기 (탭 진입 시 호출)
  Future<void> loadChatRooms() async {
    state = state.copyWith(isLoading: true);

    try {
      final chatRooms = await _repository.getChatRoomsByLocation(
        userId: currentUserId,
        address: currentAddress,
      );

      state = state.copyWith(chatRooms: chatRooms, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // 실시간 채팅방 목록 수신
  void startChatRoomsStream() {
    _repository
        .getChatRoomsStream(userId: currentUserId, address: currentAddress)
        .listen((chatRooms) {
          state = state.copyWith(chatRooms: chatRooms);
        });
  }

  // 마지막 메시지 업데이트
  Future<void> updateLastMessage({
    required String roomId,
    required ChatMessage lastMessage,
  }) async {
    try {
      await _repository.updateLastMessage(
        roomId: roomId,
        lastMessage: lastMessage,
      );
    } catch (e) {
      // 에러 발생 시 무시
    }
  }
}

// ViewModel 제공
final chatRoomListViewModelProvider =
    StateNotifierProvider<ChatRoomListViewModel, ChatRoomListState>((ref) {
      // 사용자 정보 가져오기
      final currentUserAsync = ref.watch(currentUserProvider);
      final currentUser = currentUserAsync.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );

      return ChatRoomListViewModel(
        repository: ref.read(chatRoomRepositoryProvider),
        currentUser: currentUser, // 실제 사용자 정보 전달
      );
    });
