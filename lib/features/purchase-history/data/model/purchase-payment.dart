import 'package:pos/models/payment-data.dart';

class PurchasePayment {
  final int id;
  final int purchaseId;
  final int paymentDataId;
  final double amount;
  final String type;
  final PaymentData? paymentData;

  PurchasePayment({
    required this.id,
    required this.purchaseId,
    required this.paymentDataId,
    required this.amount,
    required this.type,
    this.paymentData,
  });

  factory PurchasePayment.fromJson(Map<String, dynamic> json) {
    // debugPrint("refund payment $json");
    return PurchasePayment(
      id: json['id'],
      purchaseId: json['purchaseId'],
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

class PurchasePaymentNotExistError implements Exception {}

class AddPurchasePaymentError implements Exception {}
