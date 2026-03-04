import 'dart:convert';

import 'package:pos/models/payment-data.dart';
import 'package:pos/models/voucher-detail.dart';

class Repay {
  final int id;
  final int voucherId;
  final VoucherDetailModel voucher;
  final int userId;
  final int companyId;
  final int? branchId;
  final int paymentDataId;
  final PaymentData paymentData;
  final String? photoUrl;
  final double amount;
  final DateTime createdAt;

  Repay({
    required this.id,
    required this.voucherId,
    required this.voucher,
    required this.userId,
    required this.companyId,
    this.branchId,
    required this.paymentDataId,
    required this.paymentData,
    this.photoUrl,
    required this.amount,
    required this.createdAt,
  });

  /// From JSON
  factory Repay.fromJson(Map<String, dynamic> json) {
    //print("repay json 🤬 $json");
    return Repay(
      id: json['id'],
      voucherId: json['voucherId'],
      voucher: VoucherDetailModel.fromJson(json["voucher"]),
      userId: json['userId'],
      companyId: json['companyId'],
      branchId: json['branchId'],
      paymentDataId: json['paymentDataId'],
      paymentData: PaymentData.fromJson(json["paymentData"]),
      photoUrl: json['photoUrl'],
      amount: double.parse(json['amount'].toString()),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voucherId': voucherId,
      'userId': userId,
      'companyId': companyId,
      'branchId': branchId,
      'paymentDataId': paymentDataId,
      'photoUrl': photoUrl,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// CopyWith (very useful for Riverpod state updates)
  Repay copyWith({
    int? id,
    int? voucherId,
    VoucherDetailModel? voucher,
    int? userId,
    int? companyId,
    int? branchId,
    int? paymentDataId,
    PaymentData? paymentData,
    String? photoUrl,
    double? amount,
    DateTime? createdAt,
  }) {
    return Repay(
      id: id ?? this.id,
      voucherId: voucherId ?? this.voucherId,
      voucher: voucher ?? this.voucher,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      paymentDataId: paymentDataId ?? this.paymentDataId,
      paymentData: paymentData ?? this.paymentData,
      photoUrl: photoUrl ?? this.photoUrl,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static List<Repay> listFromJson(List<dynamic> list) {
    return list.map((e) => Repay.fromJson(e)).toList();
  }

  String toRawJson() => jsonEncode(toJson());

  factory Repay.fromRawJson(String str) => Repay.fromJson(jsonDecode(str));
}
