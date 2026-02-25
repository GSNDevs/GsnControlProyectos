class Product {
  final String id;
  final String name;
  final String? sku;
  final String? category;
  final String? categoryId;
  final double defaultPrice;
  final int stockCount;
  final String? imageUrl;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    this.sku,
    this.category,
    this.categoryId,
    this.defaultPrice = 0.0,
    this.stockCount = 0,
    this.imageUrl,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      category: json['category'],
      categoryId: json['category_id'],
      defaultPrice: (json['default_price'] as num?)?.toDouble() ?? 0.0,
      stockCount: json['stock_count'] ?? 0,
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sku': sku,
      'category': category,
      'category_id': categoryId,
      'default_price': defaultPrice,
      'stock_count': stockCount,
      'image_url': imageUrl,
    };
  }
}
