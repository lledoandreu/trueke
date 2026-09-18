class ChatMessage {
  final String id;
  final String chatId;
  final String text;
  final String senderId;
  final bool isMine;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.text,
    required this.senderId,
    required this.isMine,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final sender = json['sender_id'] as String? ?? '';
    return ChatMessage(
      id: json['id'] as String? ?? '',
      chatId: json['chat_id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      senderId: sender,
      isMine: sender == currentUserId,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
