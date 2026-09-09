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
  final String? ownerId;
  final String condition;
  final String description;
  final String wanted;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  const Product({
    required this.id,
    required this.title,
    required this.images,
    this.price,
    required this.tradeType,
    required this.category,
    required this.location,
    required this.owner,
    this.ownerId,
    required this.condition,
    required this.description,
    required this.wanted,
    required this.createdAt,
    this.latitude,
    this.longitude,
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
    'owner_id': ownerId,
    'condition': condition,
    'wanted': wanted,
    'created_at': createdAt.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages.whereType<String>().toList()
        : <String>[];

    final rawTradeType = json['trade_type'];
    final tradeType = rawTradeType is String
        ? TradeType.values.firstWhere(
            (value) => value.name == rawTradeType,
            orElse: () => TradeType.trade,
          )
        : TradeType.trade;

    final rawCreatedAt = json['created_at'];
    final createdAt = rawCreatedAt is String
        ? DateTime.tryParse(rawCreatedAt) ??
              DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.fromMillisecondsSinceEpoch(0);

    final rawPrice = json['price'];
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : rawPrice is String
        ? double.tryParse(rawPrice.replaceAll(',', '.'))
        : null;

    final rawLat = json['latitude'];
    final latitude = rawLat is num ? rawLat.toDouble() : null;

    final rawLng = json['longitude'];
    final longitude = rawLng is num ? rawLng.toDouble() : null;

    return Product(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      images: images,
      price: price,
      tradeType: tradeType,
      category: json['category']?.toString() ?? 'Otros',
      location: json['location']?.toString() ?? '',
      owner: json['owner']?.toString() ?? 'Usuario',
      ownerId: json['owner_id']?.toString(),
      condition: json['condition']?.toString() ?? 'Usado',
      wanted: json['wanted']?.toString() ?? '',
      createdAt: createdAt,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
