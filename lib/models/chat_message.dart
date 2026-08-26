class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    required this.createdAt,
    this.senderId,
  });

  final String id;
  final String text;
  final bool isMine;
  final DateTime createdAt;
  final String? senderId;

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final senderId =
        json['sender_id'] as String? ?? json['senderId'] as String?;
    final createdAtRaw =
        json['created_at'] as String? ?? json['createdAt'] as String;
    final isMine = currentUserId != null && senderId == currentUserId
        ? true
        : json['isMine'] as bool? ?? false;

    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      senderId: senderId,
      isMine: isMine,
      createdAt: DateTime.parse(createdAtRaw),
    );
  }
}
