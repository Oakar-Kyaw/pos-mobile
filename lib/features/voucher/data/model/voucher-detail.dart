import 'package:pos/features/customer/data/model/customer-model.dart';
import 'package:pos/models/company.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/models/product.dart';

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
    PaymentData? paymentData,
  }) {
    return VoucherPayment(
      id: id ?? this.id,
      paymentDataId: paymentDataId ?? this.paymentDataId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      paymentData: paymentData ?? this.paymentData,
    );
  }
}

class ItemModel {
  final int id;
  final int productId;
  final Product? product; // ← nullable ပြောင်းပါ
  final String name;
  final String? photoUrl;
  int quantity;
  double price;
  double costPrice;
  double avgCostPrice;

  ItemModel({
    required this.id,
    required this.productId,
    this.product,
    required this.name,
    this.photoUrl,
    this.quantity = 0,
    this.price = 0,
    this.costPrice = 0,
    this.avgCostPrice = 0,
  });

  ItemModel copyWith({
    int? id,
    String? name,
    String? photoUrl,
    int? quantity,
    double? price,
    double? costPrice,
    double? avgCostPrice,
    int? productId,
    Product? product,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      avgCostPrice: avgCostPrice ?? this.avgCostPrice,
      productId: productId ?? this.productId,
      product: product ?? this.product,
    );
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: (json['id'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null, // ← key မပါရင် null ထားလိုက်
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0,
      costPrice: double.tryParse(json['costPrice'].toString()) ?? 0,
      avgCostPrice: double.tryParse(json['avgCostPrice'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'quantity': quantity,
      'price': price,
      'costPrice': costPrice,
      'avgCostPrice': avgCostPrice,
      'productId': productId,
      'itemId': productId,
    };
  }
}

class VoucherDetailModel {
  final int id;
  String? voucherCode;
  DateTime? createdAt;

  List<ItemModel> items;
  List<VoucherPayment> payments;
  Customer? customer;
  Company? company;

  double subTotal;
  double totalPaymentAmount;
  double deliveryFee;
  double discountPercent;
  double discountAmount;
  double remainingPaymentAmount;
  double? packagingFee;
  double total;
  double tax;
  bool? existDebt;
  bool? isRefund;
  final String? note;
  final String type;

  VoucherDetailModel({
    required this.id,
    this.voucherCode,
    this.createdAt,
    required this.items,
    required this.payments,
    this.customer,
    this.company,
    this.totalPaymentAmount = 0,
    this.deliveryFee = 0,
    this.packagingFee = 0,
    this.remainingPaymentAmount = 0,
    this.discountAmount = 0,
    this.discountPercent = 0,
    this.total = 0,
    this.subTotal = 0,
    this.tax = 0,
    this.note,
    this.existDebt,
    this.isRefund,
    required this.type,
  });

  // CopyWith
  VoucherDetailModel copyWith({
    int? id,
    List<ItemModel>? items,
    List<VoucherPayment>? payments,
    Customer? customer,
    double? total,
    double? totalPaymentAmount,
    double? deliveryFee,
    double? packagingFee,
    double? discountPercent,
    double? discountAmount,
    double? remainingPaymentAmount,
    double? subTotal,
    double? tax,
    String? note,
    String? type,
    bool? existDebt,
    bool? isRefund,
  }) {
    return VoucherDetailModel(
      id: id ?? this.id,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      customer: customer ?? this.customer,
      subTotal: subTotal ?? this.subTotal,
      total: total ?? this.total,
      totalPaymentAmount: totalPaymentAmount ?? this.totalPaymentAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      packagingFee: packagingFee ?? this.packagingFee,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercent: discountPercent ?? this.discountPercent,
      remainingPaymentAmount:
          remainingPaymentAmount ?? this.remainingPaymentAmount,
      tax: tax ?? this.tax,
      note: note ?? this.note,
      type: type ?? this.type,
      existDebt: existDebt ?? this.existDebt,
      isRefund: isRefund ?? this.isRefund,
      company: company,
    );
  }

  // From JSON
  factory VoucherDetailModel.fromJson(Map<String, dynamic> json) {
    // print("voucher detail model ${json['Customer']}, ${json['customer']}");
    return VoucherDetailModel(
      id: json['id'],
      voucherCode: json['voucherCode'] ?? "",
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,

      items: (json['items'] as List<dynamic>)
          .map((item) => ItemModel.fromJson(item))
          .toList(),
      customer: json['Customer'] != null
          ? Customer.fromJson(json['Customer'])
          : null,
      subTotal: double.parse(json['subTotal'].toString()),
      total: double.parse(json['total'].toString()),
      tax: double.parse(json['tax'].toString()),

      totalPaymentAmount: double.parse(json['totalPaymentAmount'].toString()),
      deliveryFee: double.parse(json['deliveryFee'].toString()),
      discountAmount: double.parse(json["discountAmount"].toString()),
      discountPercent: double.parse(json["discountPercent"].toString()),
      remainingPaymentAmount: double.parse(
        json['remainingPaymentAmount'].toString(),
      ),
      note: json['note'],
      type: json['type'],
      existDebt: json["existDebt"],
      isRefund: json["isRefund"],

      payments: (json['payments'] as List<dynamic>)
          .map((item) => VoucherPayment.fromJson(item))
          .toList(),

      company: json['company'] != null
          ? Company.fromJson(json['company'])
          : null,
    );
  }

  // To JSON
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
