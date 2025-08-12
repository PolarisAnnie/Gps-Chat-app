import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/data/model/chat_message.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/chat_message_repository.dart';
import 'package:gps_chat_app/data/repository/chat_room_repository.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';
import 'package:gps_chat_app/ui/pages/chat_room_list/chat_room_list_view_model.dart';

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

// Repository 제공
final chatMessageRepositoryProvider = Provider<ChatMessageRepository>((ref) {
  return ChatMessageRepository();
});

final currentUserProvider = FutureProvider<User?>((ref) async {
  return await UserRepository().getCurrentUser();
});

// 채팅 페이지 비즈니스 로직
class ChatPageViewModel extends StateNotifier<ChatPageState> {
  final ChatMessageRepository _messageRepository;
  final String roomId;
  final User? _currentUser;
  final ChatRoomRepository _roomRepository; // 소린 추가: 채팅방 관리

  ChatPageViewModel({
    required this.roomId,
    required User? currentUser,
    required ChatMessageRepository messageRepository,
    required ChatRoomRepository roomRepository, // 소린 추가: 생성자에 추가
  }) : _messageRepository = messageRepository,
       _roomRepository = roomRepository, // 소린 추가: 필드 초기화
       _currentUser = currentUser,
       super(ChatPageState());

  // 현재 사용자 정보 getter들 추가
  String get currentUserId => _currentUser?.userId ?? "";
  String get currentUserName => _currentUser?.nickname ?? "";
  String get currentAddress => _currentUser?.address ?? "";

  // 실시간 메시지 받기 시작
  void startMessageStream() {
    _messageRepository.getMessageStream(roomId).listen((messages) {
      state = state.copyWith(messages: messages);
    });
  }

  // 입력 텍스트 변경
  void onTextChanged(String text) {
    state = state.copyWith(newMessageText: text);
  }

  // 메시지 전송
  Future<void> sendMessage() async {
    if (state.newMessageText.trim().isEmpty) return;

    state = state.copyWith(isSending: true);

    try {
      // 메시지 생성
      final message = ChatMessage(
        sender: currentUserName,
        senderId: currentUserId,
        address: currentAddress,
        content: state.newMessageText.trim(),
        createdAt: DateTime.now(),
      );

      // 메시지 전송
      await _messageRepository.sendMessage(roomId: roomId, message: message);

      // 채팅방 겉에 last message 업데이트
      await _roomRepository.updateLastMessage(
        roomId: roomId,
        lastMessage: message,
      );

      // 입력창 초기화
      state = state.copyWith(newMessageText: '', isSending: false);
    } catch (e) {
      // 전송 실패 시 상태만 복구
      state = state.copyWith(isSending: false);
    }
  }

  // 전송 버튼 클릭
  void onSendPressed() {
    sendMessage();
  }

  // 내가 보낸 메시지인지 확인
  bool isMyMessage(ChatMessage message) {
    return message.isSentByMe(currentUserId);
  }
}

// ViewModel 제공 (채팅방 ID별로 생성)
final chatPageViewModelProvider =
    StateNotifierProvider.family<ChatPageViewModel, ChatPageState, String>((
      ref,
      roomId,
    ) {
      // 사용자 정보 가져오기 추가
      final currentUserAsync = ref.watch(currentUserProvider);
      final currentUser = currentUserAsync.asData?.value;

      return ChatPageViewModel(
        roomId: roomId,
        currentUser: currentUser,
        messageRepository: ref.read(chatMessageRepositoryProvider),
        roomRepository: ref.read(chatRoomRepositoryProvider), // 소린 추가: 의존성 추가
      );
    });
