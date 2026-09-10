class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String condition;
  final String status;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
    );
  }
}
