import 'package:pos/models/company.dart';
import 'package:pos/models/payment-data.dart';

class VoucherPayment {
  String? id;
  int? paymentDataId;
  double amount;
  String type;
  PaymentData? paymentData;

  VoucherPayment({
    this.id,
    this.paymentDataId,
    this.paymentData,
    required this.amount,
    required this.type,
  });

  // Optional: factory from JSON
  factory VoucherPayment.fromJson(Map<String, dynamic> json) {
    return VoucherPayment(
      paymentDataId: json['paymentDataId'] as int,
      amount: double.parse(json['amount'].toString()),
      type: (json["type"]),
      paymentData: json["paymentData"] != null
          ? PaymentData.fromJson(json["paymentData"])
          : null,
    );
  }

  // Optional: convert to JSON
  Map<String, dynamic> toJson() {
    return {'paymentDataId': paymentDataId, 'amount': amount, 'type': type};
  }

  VoucherPayment copyWith({
    String? id,
    int? paymentDataId,
    double? amount,
    String? type,
  }) {
    return VoucherPayment(
      id: id ?? this.id,
      paymentDataId: paymentDataId ?? this.paymentDataId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
    );
  }
}

class ItemModel {
  final int id;
  // final int itemId;
  final String name;
  final String? photoUrl;
  int quantity;
  double price;

  ItemModel({
    required this.id,
    // required this.itemId,
    required this.name,
    this.photoUrl,
    this.quantity = 0,
    this.price = 0,
  });

  // CopyWith method
  ItemModel copyWith({
    int? id,
    // int? itemId,
    String? name,
    String? photoUrl,
    int? quantity,
    double? price,
  }) {
    return ItemModel(
      id: id ?? this.id,
      // itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  // Convert JSON map to ItemModel
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: (json['id'] as num).toInt(),
      name: json['name'],
      photoUrl: json['photoUrl'],
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
    );
  }

  // Convert ItemModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'itemId': id,
      'name': name,
      'photoUrl': photoUrl,
      'quantity': quantity,
      'price': price,
    };
  }
}

class VoucherDetailModel {
  final int id;
  String? voucherCode;
  DateTime? createdAt; // ✅ NEW

  List<ItemModel> items;
  List<VoucherPayment> payments;
  Company? company;

  double subTotal;
  double totalPaymentAmount;
  double deliveryFee;
  double remainingPaymentAmount;
  double total;
  double tax;

  final String? note;
  final String type;

  VoucherDetailModel({
    required this.id,
    this.voucherCode, // ✅ NEW
    this.createdAt, // ✅ NEW
    required this.items,
    required this.payments,
    this.company,
    this.totalPaymentAmount = 0,
    this.deliveryFee = 0,
    this.remainingPaymentAmount = 0,
    this.total = 0,
    this.subTotal = 0,
    this.tax = 0,
    this.note,
    required this.type,
  });

  // ✅ CopyWith
  VoucherDetailModel copyWith({
    int? id,
    List<ItemModel>? items,
    List<VoucherPayment>? payments,
    double? total,
    double? totalPaymentAmount,
    double? deliveryFee,
    double? remainingPaymentAmount,
    double? subTotal,
    double? tax,
    String? note,
    String? type,
  }) {
    return VoucherDetailModel(
      id: id ?? this.id,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      subTotal: subTotal ?? this.subTotal,
      total: total ?? this.total,
      totalPaymentAmount: totalPaymentAmount ?? this.totalPaymentAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      remainingPaymentAmount:
          remainingPaymentAmount ?? this.remainingPaymentAmount,
      tax: tax ?? this.tax,
      note: note ?? this.note,
      type: type ?? this.type,
      company: company,
    );
  }

  // ✅ From JSON
  factory VoucherDetailModel.fromJson(Map<String, dynamic> json) {
    return VoucherDetailModel(
      id: json['id'],
      voucherCode: json['voucherCode'] ?? "",
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,

      items: (json['items'] as List<dynamic>)
          .map((item) => ItemModel.fromJson(item))
          .toList(),

      subTotal: double.parse(json['subTotal'].toString()),
      total: double.parse(json['total'].toString()),
      tax: double.parse(json['tax'].toString()),
      totalPaymentAmount: double.parse(json['totalPaymentAmount'].toString()),
      deliveryFee: double.parse(json['deliveryFee'].toString()),
      remainingPaymentAmount: double.parse(
        json['remainingPaymentAmount'].toString(),
      ),
      note: json['note'],
      type: json['type'],

      payments: (json['payments'] as List<dynamic>)
          .map((item) => VoucherPayment.fromJson(item))
          .toList(),

      company: json['company'] != null
          ? Company.fromJson(json['company'])
          : null,
    );
  }

  // ✅ To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voucherCode': voucherCode,
      'createdAt': createdAt?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'subTotal': subTotal,
      'totalPaymentAmount': totalPaymentAmount,
      "deliveryFee": deliveryFee,
      "remainingPaymentAmount": remainingPaymentAmount,
      'payments': payments.map((p) => p.toJson()).toList(),
      'tax': tax,
      'note': note,
      'type': type,
    };
  }
}
