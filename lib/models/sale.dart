
class Sale {
  final String id;
  final String? label;
  final List<SaleItem> items;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final String paymentMethod;
  final String status;
  final String userId;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  Sale({
    required this.id,
    this.label,
    required this.items,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.paymentMethod,
    this.status = 'completed',
    required this.userId,
    DateTime? createdAt,
    this.cancelledAt,
    this.cancellationReason,
  }) : createdAt = createdAt ?? DateTime.now();

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'paymentMethod': paymentMethod,
      'status': status,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    List<SaleItem> items = [];
    if (json['items'] is List) {
      items = (json['items'] as List)
          .map((item) => SaleItem.fromJson(item))
          .toList();
    }

    return Sale(
      id: json['id'],
      label: json['label'],
      items: items,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      finalAmount: (json['finalAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'Dinheiro',
      status: json['status'] ?? 'completed',
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
      cancellationReason: json['cancellationReason'],
    );
  }

  Sale copyWith({
    String? id,
    String? label,
    List<SaleItem>? items,
    double? totalAmount,
    double? discountAmount,
    double? finalAmount,
    String? paymentMethod,
    String? status,
    String? userId,
    DateTime? createdAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return Sale(
      id: id ?? this.id,
      label: label ?? this.label,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}

class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }
}
