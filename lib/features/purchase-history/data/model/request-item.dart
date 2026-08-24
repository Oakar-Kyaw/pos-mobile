import 'package:pos/models/product.dart';

class RequestItem {
  final int id;
  final int productId;
  final int purchaseId;

  final int quantity;

  final double price;
  final double costPrice;

  final DateTime createdAt;

  final Product? product;

  RequestItem({
    required this.id,
    required this.productId,
    required this.purchaseId,
    required this.quantity,
    required this.price,
    required this.costPrice,
    required this.createdAt,
    this.product,
  });

  factory RequestItem.fromJson(Map<String, dynamic> json) {
    return RequestItem(
      id: json['id'],
      productId: json['productId'],
      purchaseId: json['purchaseId'],
      quantity: json['quantity'],

      price: double.tryParse(json['price'].toString()) ?? 0,

      costPrice: double.tryParse(json['costPrice'].toString()) ?? 0,

      createdAt: DateTime.parse(json['createdAt']),

      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
    );
  }

  static List<RequestItem> listFromJson(List<dynamic> data) {
    return data.map((e) => RequestItem.fromJson(e)).toList();
  }
}
