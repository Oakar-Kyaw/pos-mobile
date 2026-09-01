import 'package:pos/models/payment-data.dart';

class GeneralExpense {
  final int id;
  final String title;
  final String? reason;
  final double amount;
  final DateTime date;
  final List<GeneralExpensePayment> generalExpensePayment;

  GeneralExpense({
    required this.id,
    required this.title,
    this.reason,
    required this.amount,
    required this.date,
    required this.generalExpensePayment,
  });

  // 🔄 From JSON
  factory GeneralExpense.fromJson(Map<String, dynamic> json) {
    return GeneralExpense(
      id: json['id'],
      title: json['title'],
      reason: json['reason'],
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['date']),
      generalExpensePayment:
          (json['generalExpensePayment'] as List<dynamic>?)
              ?.map(
                (e) =>
                    GeneralExpensePayment.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  // 🔄 To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'reason': reason,
      'amount': amount.toString(),
      'date': date.toIso8601String(),
      'generalExpensePayment': generalExpensePayment
          .map((e) => e.toJson())
          .toList(),
    };
  }
}

class GeneralExpensePayment {
  final int id;
  final int generalExpenseId;
  final int paymentDataId;
  final double amount;
  final String type;
  final PaymentData? paymentData;

  GeneralExpensePayment({
    required this.id,
    required this.generalExpenseId,
    required this.paymentDataId,
    required this.amount,
    required this.type,
    this.paymentData,
  });

  factory GeneralExpensePayment.fromJson(Map<String, dynamic> json) {
    return GeneralExpensePayment(
      id: json['id'],
      generalExpenseId: json['generalExpenseId'],
      paymentDataId: json['paymentDataId'],
      amount: double.parse(json['amount'].toString()),
      type: json['type'],
      paymentData: json['paymentData'] != null
          ? PaymentData.fromJson(json['paymentData'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentDataId': paymentDataId,
      'amount': amount.toString(),
      'type': type,
      'paymentData': paymentData?.toJson(),
    };
  }
}

class generalExpensePaymentNotExistError implements Exception {}
