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
  User? _currentUser;
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

  // 사용자 정보 설정 메서드 추가
  void setCurrentUser(User? user) {
    _currentUser = user;
    print('🟡 사용자 정보 설정: ${user?.nickname}');
  }

  // 현재 사용자 정보 반환 메서드 추가
  User? getCurrentUser() {
    return _currentUser;
  }

  // 현재 사용자 정보 getter들 추가
  String get currentUserId => _currentUser?.userId ?? "";
  String get currentUserName => _currentUser?.nickname ?? "";
  String get currentAddress => _currentUser?.address ?? "";

  // 실시간 메시지 받기 시작
  void startMessageStream() async {
    print('🟡 startMessageStream 호출됨 - roomId: $roomId');

    try {
      // 1. 먼저 기존 메시지들 로딩
      final initialMessages = await _messageRepository.getMessages(roomId);
      state = state.copyWith(messages: initialMessages);
      print('🟡 초기 메시지 로딩: ${initialMessages.length}개');

      // 2. 그 다음 실시간 스트림 시작
      _messageRepository.getMessageStream(roomId).listen((messages) {
        print('🟡 스트림 메시지 수신: ${messages.length}개');
        state = state.copyWith(messages: messages);
      });
    } catch (e) {
      print('🔴 메시지 로딩 에러: $e');
    }
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
      return ChatPageViewModel(
        roomId: roomId,
        currentUser: null, // 나중에 설정
        messageRepository: ref.read(chatMessageRepositoryProvider),
        roomRepository: ref.read(chatRoomRepositoryProvider), // 소린 추가: 의존성 추가
      );
    });
