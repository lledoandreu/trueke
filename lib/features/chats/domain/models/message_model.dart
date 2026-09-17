class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'chat_id': chatId,
    'sender_id': senderId,
    'text': text,
    'created_at': createdAt.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['created_at'];
    final createdAt = rawCreatedAt is String
        ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
        : DateTime.now();

    return Message(
      id: json['id']?.toString() ?? '',
      chatId: json['chat_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      createdAt: createdAt,
    );
  }
}
