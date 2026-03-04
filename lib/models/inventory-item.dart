import 'package:pos/models/product.dart';

class InventoryItem {
  final int? id;
  final int inventoryId;
  final int productId;
  final Product product;
  final String? photoUrl;
  final int quantity;
  final double price;
  final double totalAmount;
  final DateTime? createdAt;

  InventoryItem({
    this.id,
    required this.inventoryId,
    required this.productId,
    required this.product,
    this.photoUrl,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    this.createdAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      inventoryId: json['inventoryId'],
      productId: json['productId'],
      product: Product.fromJson(json['product']),
      photoUrl: json['photoUrl'],
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      totalAmount: double.parse(json['totalAmount'].toString()),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "photoUrl": photoUrl,
      "quantity": quantity,
      "price": price,
      "totalAmount": totalAmount,
    };
  }

  InventoryItem copyWith({
    int? id,
    int? inventoryId,
    int? productId,
    Product? product,
    String? photoUrl,
    int? quantity,
    double? price,
    double? totalAmount,
    DateTime? createdAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      inventoryId: inventoryId ?? this.inventoryId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      photoUrl: photoUrl ?? this.photoUrl,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
