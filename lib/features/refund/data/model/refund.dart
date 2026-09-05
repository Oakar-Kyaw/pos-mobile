import 'package:pos/features/voucher/data/model/voucher-detail.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/features/refund/data/model/refund-item.dart';

class Refund {
  final int id;
  final String refundType;
  final int? voucherId;
  final double amount;
  final DateTime date;
  final String? reason;
  final List<RefundItem> refundItems;
  final List<RefundPayment> refundPayments;
  final VoucherDetailModel? voucher;
  final DateTime createdAt;

  Refund({
    required this.id,
    required this.refundType,
    required this.amount,
    required this.date,
    this.voucherId,
    this.reason,
    required this.refundPayments,
    required this.refundItems,
    this.voucher,
    required this.createdAt,
  });

  // ================= FROM JSON =================
  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      id: json['id'],
      refundType: json["refundType"],
      voucherId: json['voucherId'],
      date: DateTime.parse(json['date']),
      amount: double.parse(json['amount'].toString()),
      reason: json['reason'],
      voucher: json['voucher'] != null
          ? VoucherDetailModel.fromJson(json['voucher'])
          : null,
      refundItems: json['refundItems'] != null
          ? List<RefundItem>.from(
              json['refundItems'].map((item) => RefundItem.fromJson(item)),
            )
          : [],
      refundPayments: json['refundPayment'] != null
          ? List<RefundPayment>.from(
              json['refundPayment'].map((item) => RefundPayment.fromJson(item)),
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
      'voucherId': voucherId,
      'refundItems': refundItems.map((item) => item.toJson()).toList(),
      'refundPayment': refundPayments.map((item) => item.toJson()).toList(),
    };
  }
}

class RefundPayment {
  final int id;
  final int refundId;
  final int paymentDataId;
  final double amount;
  final String type;
  final PaymentData? paymentData;

  RefundPayment({
    required this.id,
    required this.refundId,
    required this.paymentDataId,
    required this.amount,
    required this.type,
    this.paymentData,
  });

  factory RefundPayment.fromJson(Map<String, dynamic> json) {
    // debugPrint("refund payment $json");
    return RefundPayment(
      id: json['id'],
      refundId: json['refundId'],
      paymentDataId: json['paymentDataId'],
      paymentData: json['paymentData'] != null
          ? PaymentData.fromJson(json['paymentData'])
          : null,
      amount: double.parse(json['amount'].toString()),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentDataId': paymentDataId,
      'amount': amount.toString(),
      'type': type,
    };
  }
}

class refundPaymentNotExistError implements Exception {}

class NotSelectVoucherError implements Exception {}

class AddRefundItemError implements Exception {}

class AddRefundPaymentError implements Exception {}

class AlreadyRefunded implements Exception {}
