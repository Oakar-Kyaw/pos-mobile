import 'package:pos/models/product.dart';

class PurchaseItem {
  final int id;
  final int productId;
  final int purchaseId;

  final int quantity;

  final double price;

  final Product? product;

  PurchaseItem({
    required this.id,
    required this.productId,
    required this.purchaseId,
    required this.quantity,
    required this.price,
    this.product,
  });

  PurchaseItem copyWith({
    int? id,
    int? productId,
    int? purchaseId,
    int? quantity,
    double? price,
    Product? product,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      purchaseId: purchaseId ?? this.purchaseId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      product: product ?? this.product,
    );
  }

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'],
      productId: json['productId'],
      purchaseId: json['purchaseId'],
      quantity: json['quantity'],
      price: double.tryParse(json['price'].toString()) ?? 0,
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
    );
  }
}
