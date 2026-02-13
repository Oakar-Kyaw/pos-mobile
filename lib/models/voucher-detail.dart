class ItemModel {
  final int id;
  final String name;
  final String? photoUrl;
  int quantity;
  double price;

  ItemModel({
    required this.id,
    required this.name,
    this.photoUrl,
    this.quantity = 0,
    this.price = 0,
  });

  // CopyWith method
  ItemModel copyWith({
    int? id,
    String? name,
    String? photoUrl,
    int? quantity,
    double? price,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  // Convert JSON map to ItemModel
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? 0,
    );
  }

  // Convert ItemModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'quantity': quantity,
      'price': price,
    };
  }
}

class VoucherDetailModel {
  final int id;
  List<ItemModel> items;
  double subTotal;
  double total;
  double tax;
  final String? note;
  final String type;

  VoucherDetailModel({
    required this.id,
    required this.items,
    this.total = 0,
    this.subTotal = 0,
    this.tax = 0,
    this.note,
    required this.type,
  });

  // CopyWith method
  VoucherDetailModel copyWith({
    int? id,
    List<ItemModel>? items,
    double? total,
    double? subTotal,
    double? tax,
    String? note,
    String? type,
  }) {
    return VoucherDetailModel(
      id: id ?? this.id,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      total: total ?? this.total,
      tax: tax ?? this.tax,
      note: note ?? this.note,
      type: type ?? this.type,
    );
  }

  // From JSON
  factory VoucherDetailModel.fromJson(Map<String, dynamic> json) {
    return VoucherDetailModel(
      id: json['id'],
      items: (json['items'] as List<dynamic>)
          .map((item) => ItemModel.fromJson(item))
          .toList(),
      subTotal: (json['subTotal'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      note: json['note'],
      type: json['type'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'subTotal': subTotal,
      'tax': tax,
      'note': note,
      'type': type,
    };
  }
}
