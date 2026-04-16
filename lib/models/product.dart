class Product {
  final String id;
  final String name;
  final String description;
  final double costPrice;
  final double sellingPrice;
  final int quantity;
  final String category;
  final String? imagePath;
  final String sku;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.costPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.category,
    this.imagePath,
    required this.sku,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get profit => sellingPrice - costPrice;
  double get profitMargin => profit > 0 ? (profit / sellingPrice) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'category': category,
      'imagePath': imagePath,
      'sku': sku,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      costPrice: (json['costPrice'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      quantity: json['quantity'] ?? 0,
      category: json['category'] ?? 'Geral',
      imagePath: json['imagePath'],
      sku: json['sku'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? costPrice,
    double? sellingPrice,
    int? quantity,
    String? category,
    String? imagePath,
    String? sku,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      sku: sku ?? this.sku,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
