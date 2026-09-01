class Product {
  final int id;
  final String name;
  final String code;
  final String? barcode;
  final String? description;
  final String? photoUrl;
  final double price;
  final double memberSellingPrice;
  final double vipSellingPrice;
  final double vvipSellingPrice;
  final double? costPrice;
  final double avgCostPrice;
  final int stock;
  final int? minStock;
  final bool isActive;
  final bool isDeleted;
  final int? categoryId;
  final int userId;
  final int companyId;
  final int? branchId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.code,
    this.barcode,
    this.description,
    this.photoUrl,
    required this.price,
    required this.memberSellingPrice,
    required this.vipSellingPrice,
    required this.vvipSellingPrice,
    this.costPrice,
    required this.avgCostPrice,
    required this.stock,
    this.minStock,
    required this.isActive,
    required this.isDeleted,
    this.categoryId,
    required this.userId,
    required this.companyId,
    this.branchId,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      code: json['code'],
      barcode: json['barcode'],
      description: json['description'],
      photoUrl: json['photoUrl'],
      price: double.parse(json['price'].toString()),
      memberSellingPrice: double.parse(json['memberSellingPrice'].toString()),
      vipSellingPrice: double.parse(json['vipSellingPrice'].toString()),
      vvipSellingPrice: double.parse(json['vvipSellingPrice'].toString()),
      costPrice: json['costPrice'] != null
          ? double.parse(json['costPrice'].toString())
          : null,
      avgCostPrice: double.parse(json['avgCostPrice'].toString()),
      stock: int.parse(json['stock'].toString()),
      minStock: json['minStock'] != null
          ? int.parse(json['minStock'].toString())
          : null,
      isActive: json['isActive'],
      isDeleted: json['isDeleted'],
      categoryId: json['categoryId'] != null
          ? int.parse(json['categoryId'].toString())
          : null,
      userId: int.parse(json['userId'].toString()),
      companyId: int.parse(json['companyId'].toString()),
      branchId: json['branchId'] != null
          ? int.parse(json['branchId'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'barcode': barcode,
      'description': description,
      'photoUrl': photoUrl,
      'price': price,
      'memberSellingPrice': memberSellingPrice,
      'vipSellingPrice': vipSellingPrice,
      'vvipSellingPrice': vvipSellingPrice,
      'costPrice': costPrice,
      'avgCostPrice': avgCostPrice,
      'stock': stock,
      'minStock': minStock,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'categoryId': categoryId,
      'userId': userId,
      'companyId': companyId,
      'branchId': branchId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
