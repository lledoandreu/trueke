class Product {
  final String id;
  final String title;
  final String description;
  final double?
  price; // Opcional, si los intercambios admiten compensación económica
  final List<String> imageUrls;
  final String ownerId;
  final String status; // 'available', 'reserved', 'traded'
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    this.price,
    required this.imageUrls,
    required this.ownerId,
    required this.status,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      imageUrls:
          (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ownerId: json['owner_id'] as String,
      status: json['status'] as String? ?? 'available',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image_urls': imageUrls,
      'owner_id': ownerId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    List<String>? imageUrls,
    String? ownerId,
    String? status,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
