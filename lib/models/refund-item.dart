import 'package:pos/models/product.dart';

class RefundItem {
  final int id;
  final int? productId;
  final Product product;
  final int quantity;
  final double price;
  final DateTime createdAt;

  RefundItem({
    required this.id,
    this.productId,
    required this.product,
    required this.quantity,
    required this.price,
    required this.createdAt,
  });

  factory RefundItem.fromJson(Map<String, dynamic> json) {
    return RefundItem(
      id: json['id'],
      productId: json['productId'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'quantity': quantity, 'price': price};
  }

  RefundItem copyWith({
    int? id,
    int? productId,
    Product? product,
    int? quantity,
    double? price,
    DateTime? createdAt,
  }) {
    return RefundItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
