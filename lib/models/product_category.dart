class ProductCategory {
  final String id;
  final String name;
  final DateTime createdAt;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
