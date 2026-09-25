import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    @JsonKey(name: 'room_id') required String roomId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String message,
    @JsonKey(name: 'is_system') @Default(false) bool isSystem,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
