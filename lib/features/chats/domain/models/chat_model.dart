import 'message_model.dart';

class Chat {
  final String id;
  final List<String> participantIds;
  final String productId;
  final DateTime updatedAt;
  final Message? lastMessage;

  const Chat({
    required this.id,
    required this.participantIds,
    required this.productId,
    required this.updatedAt,
    this.lastMessage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'participant_ids': participantIds,
    'product_id': productId,
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Chat.fromJson(Map<String, dynamic> json) {
    final rawParticipantIds = json['participant_ids'];
    final participantIds = rawParticipantIds is List
        ? rawParticipantIds.whereType<String>().toList()
        : <String>[];

    final rawUpdatedAt = json['updated_at'];
    final updatedAt = rawUpdatedAt is String
        ? DateTime.tryParse(rawUpdatedAt) ?? DateTime.now()
        : DateTime.now();

    final rawLastMessage = json['last_message'];
    final lastMessage = rawLastMessage is Map<String, dynamic>
        ? Message.fromJson(rawLastMessage)
        : null;

    return Chat(
      id: json['id']?.toString() ?? '',
      participantIds: participantIds,
      productId: json['product_id']?.toString() ?? '',
      updatedAt: updatedAt,
      lastMessage: lastMessage,
    );
  }
}
