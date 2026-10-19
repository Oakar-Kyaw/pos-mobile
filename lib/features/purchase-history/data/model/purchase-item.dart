import 'package:pos/models/product.dart';

class PurchaseItem {
  final int id;
  final int productId;
  final int purchaseId;

  final int quantity;

  final double price;

  //selling price
  final double sellingPrice;

  final Product? product;

  PurchaseItem({
    required this.id,
    required this.productId,
    required this.purchaseId,
    required this.quantity,
    required this.price,
    required this.sellingPrice,
    this.product,
  });

  PurchaseItem copyWith({
    int? id,
    int? productId,
    int? purchaseId,
    int? quantity,
    double? price,
    double? sellingPrice,
    Product? product,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      purchaseId: purchaseId ?? this.purchaseId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      sellingPrice: sellingPrice ?? this.sellingPrice,
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
      sellingPrice: double.tryParse(json['sellingPrice'].toString()) ?? 0,
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
    );
  }
}
