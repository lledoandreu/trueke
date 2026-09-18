import 'chat_message.dart';

class ChatConversation {
  final String id;
  final String name;
  final String product;
  final String? productId;
  final String? buyerId;
  final String? sellerId;
  final List<ChatMessage> messages;

  const ChatConversation({
    required this.id,
    required this.name,
    required this.product,
    this.productId,
    this.buyerId,
    this.sellerId,
    this.messages = const [],
  });

  String? get lastMessageText => messages.isEmpty ? null : messages.last.text;

  ChatConversation copyWith({List<ChatMessage>? messages}) {
    return ChatConversation(
      id: id,
      name: name,
      product: product,
      productId: productId,
      buyerId: buyerId,
      sellerId: sellerId,
      messages: messages ?? this.messages,
    );
  }

  factory ChatConversation.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final buyer = json['buyer_id'] as String?;
    final sellerName = json['seller_name'] as String? ?? 'Usuario';
    final buyerName = json['buyer_name'] as String? ?? 'Usuario';
    final isBuyer = buyer == currentUserId;

    return ChatConversation(
      id: json['id'] as String? ?? '',
      name: isBuyer ? sellerName : buyerName,
      product:
          json['product_title'] as String? ??
          json['product_id'] as String? ??
          '',
      productId: json['product_id'] as String?,
      buyerId: buyer,
      sellerId: json['seller_id'] as String?,
      messages: const [],
    );
  }
}
