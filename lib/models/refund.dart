import 'package:pos/models/refund-item.dart';
import 'package:pos/models/voucher-detail.dart';

class Refund {
  final int id;
  final int? voucherId;
  final double amount;
  final String? reason;
  final String paymentType;
  final List<RefundItem> refundItems;
  final VoucherDetailModel? voucher;
  final DateTime createdAt;

  Refund({
    required this.id,
    required this.amount,
    this.voucherId,
    this.reason,
    required this.paymentType,
    required this.refundItems,
    this.voucher,
    required this.createdAt,
  });

  // ================= FROM JSON =================
  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      id: json['id'],
      voucherId: json['voucherId'],
      amount: double.parse(json['amount'].toString()),
      reason: json['reason'],
      paymentType: json['paymentType'],
      voucher: json['voucher'] != null
          ? VoucherDetailModel.fromJson(json['voucher'])
          : null,
      refundItems: json['refundItems'] != null
          ? List<RefundItem>.from(
              json['refundItems'].map((item) => RefundItem.fromJson(item)),
            )
          : [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'reason': reason,
      'paymentType': paymentType,
      'voucherId': voucherId,
      'refundItems': refundItems.map((item) => item.toJson()).toList(),
    };
  }
}
