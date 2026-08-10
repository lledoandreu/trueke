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
    'images': images,
    'price': price,
    'tradeType': tradeType.name,
    'category': category,
    'location': location,
    'owner': owner,
    'condition': condition,
    'description': description,
    'wanted': wanted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    title: json['title'] as String,
    images: List<String>.from(json['images'] as List<dynamic>),
    price: (json['price'] as num?)?.toDouble(),
    tradeType: TradeType.values.byName(json['tradeType'] as String),
    category: json['category'] as String,
    location: json['location'] as String,
    owner: json['owner'] as String,
    condition: json['condition'] as String,
    description: json['description'] as String,
    wanted: json['wanted'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
