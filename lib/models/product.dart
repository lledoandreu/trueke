enum TradeType { trade, sale, tradeAndMoney }

class Product {
  final String id;
  final String title;
  final String imageUrl;
  final double? price;
  final TradeType tradeType;
  final String location;
  final String owner;
  final String condition;

  // NUEVOS CAMPOS
  final String description;
  final String wanted;

  const Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.price,
    required this.tradeType,
    required this.location,
    required this.owner,
    required this.condition,
    required this.description,
    required this.wanted,
  });
}
