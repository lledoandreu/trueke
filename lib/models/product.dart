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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'price': price,
    'images': images,
    'trade_type': tradeType.name,
    'category': category,
    'location': location,
    'owner': owner,
    'condition': condition,
    'wanted': wanted,
    'created_at': createdAt.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    images: List<String>.from(json['images'] ?? []),
    price: (json['price'] as num?)?.toDouble(),
    tradeType: TradeType.values.byName(json['trade_type'] as String),
    category: json['category'] as String,
    location: json['location'] as String,
    owner: json['owner'] as String,
    condition: json['condition'] as String,
    wanted: json['wanted'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
