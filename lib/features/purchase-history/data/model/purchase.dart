import 'package:pos/features/purchase-history/data/model/purchase-item.dart';
import 'package:pos/features/purchase-history/data/model/purchase-payment.dart';

import '../../../supplier/data/model/supplier.dart';

class Purchase {
  final int id;
  final DateTime createdAt;
  final DateTime orderDate;
  final DateTime? receivedDate;
  final String status;
  final String? note;
  final bool isDeleted;

  final double deliveryFee;
  final double discount;
  final double packagingFee;
  final double discountPercent;
  final double totalAmount;
  final double tax;

  final int companyId;
  final int? branchId;
  final int? supplierId;
  final int? createdBy;

  final Supplier? supplier;

  final List<PurchaseItem> purchaseItems;
  List<PurchasePayment> purchasePayments;

  Purchase({
    required this.id,
    required this.createdAt,
    required this.orderDate,
    this.receivedDate,
    required this.status,
    required this.note,
    required this.isDeleted,
    required this.deliveryFee,
    required this.packagingFee,
    required this.discountPercent,
    required this.totalAmount,
    required this.discount,
    required this.tax,
    required this.companyId,
    required this.branchId,
    required this.supplierId,
    required this.createdBy,
    required this.supplier,
    required this.purchaseItems,
    required this.purchasePayments,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      orderDate: DateTime.parse(json['orderDate']),
      receivedDate: json['receivedDate'] != null
          ? DateTime.parse(json['receivedDate'])
          : null,
      status: json['status'],
      note: json['note'],
      isDeleted: json['isDeleted'] ?? false,

      deliveryFee: double.tryParse(json['deliveryFee'].toString()) ?? 0,
      packagingFee: double.tryParse(json['packagingFee'].toString()) ?? 0,

      discount: double.tryParse(json['discount'].toString()) ?? 0,
      discountPercent: double.tryParse(json['discountPercent'].toString()) ?? 0,
      totalAmount: double.tryParse(json['totalAmount'].toString()) ?? 0,

      tax: double.tryParse(json['tax'].toString()) ?? 0,

      companyId: json['companyId'],

      branchId: json['branchId'],
      supplierId: json['supplierId'],
      createdBy: json['createdBy'],

      supplier: json['supplier'] != null
          ? Supplier.fromJson(json['supplier'])
          : null,

      purchaseItems: (json['purchaseItems'] as List? ?? [])
          .map((e) => PurchaseItem.fromJson(e))
          .toList(),

      purchasePayments: (json['purchasePayments'] as List? ?? [])
          .map((e) => PurchasePayment.fromJson(e))
          .toList(),
    );
  }

  Purchase copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? orderDate,
    DateTime? receivedDate,
    String? status,
    String? note,
    bool? isDeleted,
    double? deliveryFee,
    double? discount,
    double? packagingFee,
    double? discountPercent,
    double? totalAmount,
    double? tax,
    int? companyId,
    int? branchId,
    int? supplierId,
    int? createdBy,
    Supplier? supplier,
    List<PurchaseItem>? purchaseItems,
    List<PurchasePayment>? purchasePayments,
  }) {
    return Purchase(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      orderDate: orderDate ?? this.orderDate,
      receivedDate: receivedDate ?? this.receivedDate,
      status: status ?? this.status,
      note: note ?? this.note,
      isDeleted: isDeleted ?? this.isDeleted,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      packagingFee: packagingFee ?? this.packagingFee,
      discountPercent: discountPercent ?? this.discountPercent,
      totalAmount: totalAmount ?? this.totalAmount,
      tax: tax ?? this.tax,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      supplierId: supplierId ?? this.supplierId,
      createdBy: createdBy ?? this.createdBy,
      supplier: supplier ?? this.supplier,
      purchaseItems: purchaseItems ?? this.purchaseItems,
      purchasePayments: purchasePayments ?? this.purchasePayments,
    );
  }

  static List<Purchase> listFromJson(List<dynamic> data) {
    return data.map((e) => Purchase.fromJson(e)).toList();
  }
}
