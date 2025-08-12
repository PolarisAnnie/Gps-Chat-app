import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';
import 'package:gps_chat_app/data/repository/chat_room_repository.dart';

// 상태 모델
class ChatRoomListState {
  final List<ChatRoom> chatRooms;
  final bool isLoading;
  final String? error;

  ChatRoomListState({
    this.chatRooms = const [],
    this.isLoading = false,
    this.error,
  });

  ChatRoomListState copyWith({
    List<ChatRoom>? chatRooms,
    bool? isLoading,
    String? error,
  }) {
    return ChatRoomListState(
      chatRooms: chatRooms ?? this.chatRooms,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// ViewModel
class ChatRoomListViewModel extends StateNotifier<ChatRoomListState> {
  final ChatRoomRepository _repo;
  StreamSubscription<List<ChatRoom>>? _sub;
  bool _started = false;

  ChatRoomListViewModel(this._repo) : super(ChatRoomListState());

  /// 실시간 스트림 구독 시작
  void startChatRoomsStream({
    required String userId,
    required String address,
    bool force = false,
  }) {
    if (_started && !force) return; // 중복 구독 방지
    _started = true;

    // 기존 구독 해제
    _sub?.cancel();

    state = state.copyWith(isLoading: true, error: null);

    _sub = _repo
        .getChatRoomsStream(userId: userId, address: address)
        .listen(
          (rooms) {
            state = state.copyWith(chatRooms: rooms, isLoading: false);
          },
          onError: (e) {
            state = state.copyWith(error: e.toString(), isLoading: false);
          },
        );
  }

  /// 강제 갱신 (화면 들어올 때 사용)
  void refreshChatRooms({required String userId, required String address}) {
    startChatRoomsStream(userId: userId, address: address, force: true);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// Provider
final chatRoomListViewModelProvider =
    StateNotifierProvider<ChatRoomListViewModel, ChatRoomListState>((ref) {
      final repo = ChatRoomRepository();
      return ChatRoomListViewModel(repo);
    });
