import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/data/model/chat_message.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/chat_message_repository.dart';
import 'package:gps_chat_app/data/repository/chat_room_repository.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';

import '../chat_room_list/chat_room_list_view_model.dart';

// 채팅 페이지 상태
class ChatPageState {
  final List<ChatMessage> messages;
  final String newMessageText;
  final bool isSending;

  ChatPageState({
    this.messages = const [],
    this.newMessageText = '',
    this.isSending = false,
  });

  ChatPageState copyWith({
    List<ChatMessage>? messages,
    String? newMessageText,
    bool? isSending,
  }) {
    return ChatPageState(
      messages: messages ?? this.messages,
      newMessageText: newMessageText ?? this.newMessageText,
      isSending: isSending ?? this.isSending,
    );
  }
}

final chatMessageRepositoryProvider = Provider<ChatMessageRepository>((ref) {
  return ChatMessageRepository();
});

final currentUserProvider = FutureProvider<User?>((ref) async {
  return await UserRepository().getCurrentUser();
});

class ChatPageViewModel extends StateNotifier<ChatPageState> {
  final ChatMessageRepository _messageRepository;
  final String roomId;
  final ChatRoomRepository _roomRepository;
  User? _currentUser;
  StreamSubscription? _subscription; // 구독 관리

  ChatPageViewModel({
    required this.roomId,
    required User? currentUser,
    required ChatMessageRepository messageRepository,
    required ChatRoomRepository roomRepository,
  }) : _messageRepository = messageRepository,
       _roomRepository = roomRepository,
       _currentUser = currentUser,
       super(ChatPageState());

  void setCurrentUser(User? user) {
    _currentUser = user;
    print('🟡 사용자 정보 설정: ${user?.nickname}');
  }

  User? getCurrentUser() => _currentUser;
  String get currentUserId => _currentUser?.userId ?? "";
  String get currentUserName => _currentUser?.nickname ?? "";
  String get currentAddress => _currentUser?.address ?? "";

  // 메시지 스트림 시작
  void startMessageStream() async {
    print('🟡 startMessageStream 호출됨 - roomId: $roomId');
    _subscription?.cancel(); // 기존 구독 해제

    try {
      final initialMessages = await _messageRepository.getMessages(roomId);
      state = state.copyWith(messages: initialMessages);

      _subscription = _messageRepository.getMessageStream(roomId).listen((
        messages,
      ) {
        print('🟡 스트림 메시지 수신: ${messages.length}개');
        state = state.copyWith(messages: messages);
      });
    } catch (e) {
      print('🔴 메시지 로딩 에러: $e');
    }
  }

  // 메시지 스트림 종료
  void stopMessageStream() {
    _subscription?.cancel();
    _subscription = null;
  }

  void onTextChanged(String text) {
    state = state.copyWith(newMessageText: text);
  }

  Future<void> sendMessage() async {
    if (state.newMessageText.trim().isEmpty) return;

    state = state.copyWith(isSending: true);

    try {
      final message = ChatMessage(
        sender: currentUserName,
        senderId: currentUserId,
        address: currentAddress,
        content: state.newMessageText.trim(),
        createdAt: DateTime.now(),
      );

      await _messageRepository.sendMessage(roomId: roomId, message: message);
      await _roomRepository.updateLastMessage(
        roomId: roomId,
        lastMessage: message,
      );

      state = state.copyWith(newMessageText: '', isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false);
    }
  }

  void onSendPressed() => sendMessage();

  bool isMyMessage(ChatMessage message) {
    return message.isSentByMe(currentUserId);
  }
}

final chatPageViewModelProvider =
    StateNotifierProvider.family<ChatPageViewModel, ChatPageState, String>((
      ref,
      roomId,
    ) {
      final currentUser = ref.watch(currentUserProvider).value;
      return ChatPageViewModel(
        roomId: roomId,
        currentUser: currentUser,
        messageRepository: ref.read(chatMessageRepositoryProvider),
        roomRepository: ref.read(
          chatRoomRepositoryProvider as ProviderListenable<ChatRoomRepository>,
        ),
      );
    });
