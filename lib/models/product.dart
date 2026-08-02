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
  final bool favorite;

  const Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.price,
    required this.tradeType,
    required this.location,
    required this.owner,
    required this.condition,
    this.favorite = false,
  });
}
