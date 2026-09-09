import 'chat_message.dart';

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.name,
    required this.product,
    required this.messages,
    this.productId,
    this.buyerId,
    this.sellerId,
  });

  final String id;
  final String name;
  final String product;
  final List<ChatMessage> messages;
  final String? productId;
  final String? buyerId;
  final String? sellerId;

  /// Devuelve el texto del último mensaje si existe, de lo contrario devuelve null.
  String? get lastMessageText => messages.isEmpty ? null : messages.last.text;

  ChatConversation copyWith({List<ChatMessage>? messages}) {
    return ChatConversation(
      id: id,
      name: name,
      product: product,
      messages: messages ?? this.messages,
      productId: productId,
      buyerId: buyerId,
      sellerId: sellerId,
    );
  }

  factory ChatConversation.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final buyerId = json['buyer_id'] as String?;
    final sellerName = json['seller_name'] as String? ?? 'Usuario';
    final buyerName = json['buyer_name'] as String? ?? 'Usuario';
    final isBuyer = buyerId == currentUserId;

    final rawMessages = json['messages'] as List<dynamic>? ?? const [];

    final messages =
        rawMessages
            .map(
              (item) => ChatMessage.fromJson(
                item as Map<String, dynamic>,
                currentUserId: currentUserId,
              ),
            )
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return ChatConversation(
      id: json['id'] as String,
      name: isBuyer ? sellerName : buyerName,
      product: json['product_title'] as String? ?? '',
      productId: json['product_id'] as String?,
      buyerId: buyerId,
      sellerId: json['seller_id'] as String?,
      messages: messages,
    );
  }
}
