enum TradeType { trade, sale, tradeAndMoney }

class Product {
  final String id;

  final String title;

  final List<String> images;

  final double? price;

  final TradeType tradeType;

  final String category;

  final String location;

  final String owner;

  final String condition;

  final String description;

  final String wanted;

  final DateTime createdAt;

  const Product({
    required this.id,
    required this.title,
    required this.images,
    this.price,
    required this.tradeType,
    required this.category,
    required this.location,
    required this.owner,
    required this.condition,
    required this.description,
    required this.wanted,
    required this.createdAt,
  });

  String get imageUrl {
    if (images.isEmpty) {
      return '';
    }

    return images.first;
  }
}
