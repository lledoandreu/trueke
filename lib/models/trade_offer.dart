enum TradeOfferStatus { sent, accepted, declined }

class TradeOffer {
  const TradeOffer({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.message,
    required this.createdAt,
    this.status = TradeOfferStatus.sent,
  });

  final String id;
  final String productId;
  final String productTitle;
  final String message;
  final DateTime createdAt;
  final TradeOfferStatus status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productTitle': productTitle,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
  };

  factory TradeOffer.fromJson(Map<String, dynamic> json) => TradeOffer(
    id: json['id'] as String,
    productId: json['productId'] as String,
    productTitle: json['productTitle'] as String,
    message: json['message'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    status: TradeOfferStatus.values.byName(json['status'] as String),
  );
}
