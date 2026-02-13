class Product {
  final int id;
  final String name;
  final String code;
  final String? barcode;
  final String? description;
  final String? photoUrl;

  final double price;
  final double? costPrice;

  final int stock;
  final int? minStock;

  final bool isActive;
  final bool isDeleted;

  final int categoryId;
  final int userId;
  final int companyId;

  Product({
    required this.id,
    required this.name,
    required this.code,
    this.barcode,
    this.description,
    this.photoUrl,
    required this.price,
    this.costPrice,
    required this.stock,
    this.minStock,
    required this.isActive,
    required this.isDeleted,
    required this.categoryId,
    required this.userId,
    required this.companyId,
  });

  /// 🔹 From API JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    //print("🤖 json is: $json");
    return Product(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      code: json['code'],
      barcode: json['barcode'],
      description: json['description'],
      photoUrl: json['photoUrl'],
      price: double.parse(json['price'].toString()),
      costPrice: json['costPrice'] != null
          ? double.parse(json['costPrice'].toString())
          : null,
      stock: json['stock'],
      minStock: json['minStock'],
      isActive: json['isActive'],
      isDeleted: json['isDeleted'],
      categoryId: json['categoryId'],
      userId: json['userId'],
      companyId: json['companyId'],
    );
  }

  /// 🔹 To API JSON (create / update)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'barcode': barcode,
      'description': description,
      'photoUrl': photoUrl,
      'price': price,
      'costPrice': costPrice,
      'stock': stock,
      'minStock': minStock,
      'categoryId': categoryId,
      'companyId': companyId,
    };
  }
}
