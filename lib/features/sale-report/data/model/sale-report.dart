import 'package:flutter/widgets.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/models/user.dart';

enum TransferType {
  internal,
  external;

  static TransferType fromString(String? value) {
    switch (value) {
      case 'EXTERNAL':
        return TransferType.external;
      case 'INTERNAL':
      default:
        return TransferType.internal;
    }
  }
}

class SaleReport {
  final double openingAmount;
  final double closingAmount;
  final double totalPurchase;
  final double totalGeneralExpense;
  final double totalSaleAmount;
  final double totalPaidAmount;
  final double totalDebtAmount;
  final double totalRefundAmount;
  final double totalRepayAmount;
  final double totalTransferAmount;
  final double totalExternalTransferAmount;
  final double totalInternalTransferAmount;
  final bool isClosed;

  SaleReport({
    required this.openingAmount,
    required this.closingAmount,
    required this.totalPurchase,
    required this.totalGeneralExpense,
    required this.totalSaleAmount,
    required this.totalPaidAmount,
    required this.totalDebtAmount,
    required this.totalRefundAmount,
    required this.totalRepayAmount,
    required this.totalTransferAmount,
    required this.totalExternalTransferAmount,
    required this.totalInternalTransferAmount,
    required this.isClosed,
  });

  factory SaleReport.fromJson(Map<String, dynamic> json) {
    return SaleReport(
      openingAmount: _parseDouble(json['openingAmount']),
      closingAmount: _parseDouble(json['closingAmount']),
      totalPurchase: _parseDouble(json['totalPurchase']),
      totalGeneralExpense: _parseDouble(json['totalGeneralExpense']),
      totalSaleAmount: _parseDouble(json['totalSaleAmount']),
      totalPaidAmount: _parseDouble(json['totalPaidAmount']),
      totalDebtAmount: _parseDouble(json['totalDebtAmount']),
      totalRefundAmount: _parseDouble(json['totalRefundAmount']),
      totalRepayAmount: _parseDouble(json['totalRepayAmount']),
      totalTransferAmount: _parseDouble(json['totalTransferAmount']),
      totalExternalTransferAmount: _parseDouble(
        json['totalExternalTransferAmount'],
      ),
      totalInternalTransferAmount: _parseDouble(
        json['totalInternalTransferAmount'],
      ),
      isClosed: json['isClosed'] ?? false,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }
}

class Transfer {
  final int id;
  final DateTime date;
  final double amount;
  final TransferType transferType;
  final PaymentData fromAccount;
  final PaymentData toAccount;
  final User saleUser;

  Transfer({
    required this.id,
    required this.date,
    required this.amount,
    required this.transferType,
    required this.fromAccount,
    required this.toAccount,
    required this.saleUser,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    debugPrint("json for transfer is 😃 $json");
    return Transfer(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      transferType: TransferType.fromString(json['transferType']),
      fromAccount: PaymentData.fromJson(json['fromAccount']),
      toAccount: PaymentData.fromJson(json['toAccount']),
      saleUser: User.fromJson(json["saleUser"]),
    );
  }
}

enum TransactionType {
  openingBalance,
  sale,
  refund,
  closingBalance,
  expense,
  unknown;

  static TransactionType fromString(String? value) {
    switch (value) {
      case 'OPENING_BALANCE':
        return TransactionType.openingBalance;
      case 'SALE':
        return TransactionType.sale;
      case 'REFUND':
        return TransactionType.refund;
      case 'CLOSING_BALANCE':
        return TransactionType.closingBalance;
      case 'EXPENSE':
        return TransactionType.expense;
      default:
        return TransactionType.unknown;
    }
  }

  String get label {
    switch (this) {
      case TransactionType.openingBalance:
        return 'Opening Balance';
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.closingBalance:
        return 'Closing Balance';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.unknown:
        return 'Unknown';
    }
  }
}

class SaleReportEntry {
  final int id;
  final DateTime date;
  final TransactionType type;
  final double amount;
  final String? description;
  final bool isClosed;
  final User saleUser;

  SaleReportEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.isClosed,
    required this.saleUser,
    this.description,
  });

  factory SaleReportEntry.fromJson(Map<String, dynamic> json) {
    return SaleReportEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: TransactionType.fromString(json['type']),
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      isClosed: json['isClosed'] ?? false,
      description: json['description'],
      saleUser: User.fromJson(json['saleUser']),
    );
  }
}
