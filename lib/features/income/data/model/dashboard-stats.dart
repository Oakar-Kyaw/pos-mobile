import 'package:flutter/cupertino.dart';

class DashboardStats {
  final SaleSummary yearlySale;
  final SaleSummary monthlySale;
  final List<SaleItem> mostSellingItem;
  final List<SaleItem> leastSellingItem;
  final List<MonthlySale> getMonthByMonth;
  final List<MonthlyTopSaleUser> getMonthlyTopSaleUser;
  final SaleSummary getTodaySale;

  DashboardStats({
    required this.yearlySale,
    required this.monthlySale,
    required this.mostSellingItem,
    required this.leastSellingItem,
    required this.getMonthByMonth,
    required this.getMonthlyTopSaleUser,
    required this.getTodaySale,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      yearlySale: SaleSummary.fromJson(json['yearlySale']),
      monthlySale: SaleSummary.fromJson(json['monthlySale']),
      mostSellingItem: (json['mostSellingItem'] as List)
          .map((e) => SaleItem.fromJson(e))
          .toList(),
      leastSellingItem: (json['leastSellingItem'] as List)
          .map((e) => SaleItem.fromJson(e))
          .toList(),
      getMonthByMonth: (json['getMonthByMonth'] as List)
          .map((e) => MonthlySale.fromJson(e))
          .toList(),
      getMonthlyTopSaleUser: (json['getMonthlyTopSaleUser'] as List)
          .map((e) => MonthlyTopSaleUser.fromJson(e))
          .toList(),
      getTodaySale: SaleSummary.fromJson(json['getTodaySale']),
    );
  }
}

// ──────────────────────────────
// Sale Summary
// ──────────────────────────────
class SaleSummary {
  final String total;
  final String deliveryFee;
  final String tax;
  final String packagingFee;
  final String discountAmount;
  final String discountPercent;
  final String subTotal;
  final String refundAmount;
  final String debtAmount;
  final String expenseAmount;
  final String purchaseAmount;
  final String netIncome;
  final String totalPaymentAmount;
  // final String openingAmount;
  // final String transferAmount;

  SaleSummary({
    required this.total,
    required this.packagingFee,
    required this.discountAmount,
    required this.discountPercent,
    required this.deliveryFee,
    required this.tax,
    required this.subTotal,
    required this.refundAmount,
    required this.debtAmount,
    required this.expenseAmount,
    required this.purchaseAmount,
    required this.netIncome,
    required this.totalPaymentAmount,
    // required this.openingAmount,
    // required this.transferAmount,
  });

  factory SaleSummary.fromJson(Map<String, dynamic> json) {
    // debugPrint("sale summary $json");
    return SaleSummary(
      total: json['total'],
      deliveryFee: json['deliveryFee'],
      packagingFee: json['packagingFee'],
      discountAmount: json['discountAmount'],
      discountPercent: json['discountPercent'],
      tax: json['tax'],
      subTotal: json['subTotal'],
      refundAmount: json['refundAmount'],
      debtAmount: json['debtAmount'],
      expenseAmount: json['expenseAmount'],
      purchaseAmount: json['purchaseAmount'],
      netIncome: json['netIncome'],
      totalPaymentAmount: json['totalPaymentAmount'],
      // openingAmount: json['openingAmount'],
      // transferAmount: json["transferAmount"],
    );
  }
}

// ──────────────────────────────
// Sale Item (most / least selling)
// ──────────────────────────────
class SaleItem {
  final int itemId;
  final String name;
  final int totalQuantity;

  SaleItem({
    required this.itemId,
    required this.name,
    required this.totalQuantity,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      itemId: json['itemId'] ?? json['itemid'], // handle case-insensitive keys
      name: json['name'],
      totalQuantity: json['totalQuantity'],
    );
  }
}

// ──────────────────────────────
// Monthly Sale
// ──────────────────────────────
class MonthlySale {
  final String month;
  final String total;
  final String deliveryFee;
  final String tax;
  final String subTotal;
  final String refundAmount;
  final String debtAmount;
  final String expenseAmount;
  final String purchaseAmount;
  final String netIncome;
  final String totalPaymentAmount;
  // final String openingAmount;
  // final String transferAmount;

  MonthlySale({
    required this.month,
    required this.total,
    required this.deliveryFee,
    required this.tax,
    required this.subTotal,
    required this.refundAmount,
    required this.debtAmount,
    required this.expenseAmount,
    required this.purchaseAmount,
    required this.netIncome,
    required this.totalPaymentAmount,
    // required this.openingAmount,
    // required this.transferAmount,
  });

  factory MonthlySale.fromJson(Map<String, dynamic> json) {
    debugPrint("MOnth sale $json");
    return MonthlySale(
      month: json['month'].toString(),
      total: json['total'].toString(),
      deliveryFee: json['deliveryFee'].toString(),
      tax: json['tax'].toString(),
      subTotal: json['subTotal'].toString(),
      refundAmount: json['refundAmount'],
      debtAmount: json['debtAmount'],
      expenseAmount: json['expenseAmount'],
      purchaseAmount: json['purchaseAmount'],
      netIncome: json['netIncome'],
      totalPaymentAmount: json['paymentIn'],
      // openingAmount: json['openingAmount'],
      // transferAmount: json["transferAmount"],
    );
  }
}

// ──────────────────────────────
// Monthly Top Sale User
// ──────────────────────────────
class MonthlyTopSaleUser {
  final String? saleFirstName;
  final String? saleLastName;
  final String saleEmail;
  final String? phone;
  final int saleUserId;
  final String total;
  final String deliveryFee;
  final String tax;
  final String subTotal;

  MonthlyTopSaleUser({
    this.saleFirstName,
    this.saleLastName,
    this.phone,
    required this.saleEmail,
    required this.saleUserId,
    required this.total,
    required this.deliveryFee,
    required this.tax,
    required this.subTotal,
  });

  factory MonthlyTopSaleUser.fromJson(Map<String, dynamic> json) {
    return MonthlyTopSaleUser(
      saleFirstName: json['salefirstname'],
      saleLastName: json['salelastname'],
      phone: json["phone"] ?? "",
      saleEmail: json['saleemail'],
      saleUserId: json['saleuserid'],
      total: json['total'],
      deliveryFee: json['deliveryFee'],
      tax: json['tax'],
      subTotal: json['subTotal'],
    );
  }
}
