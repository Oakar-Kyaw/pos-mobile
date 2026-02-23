// ──────────────────────────────
// Root Dashboard Response
// ──────────────────────────────
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
  final String subTotal;

  SaleSummary({
    required this.total,
    required this.deliveryFee,
    required this.tax,
    required this.subTotal,
  });

  factory SaleSummary.fromJson(Map<String, dynamic> json) {
    return SaleSummary(
      total: json['total'],
      deliveryFee: json['deliveryFee'],
      tax: json['tax'],
      subTotal: json['subTotal'],
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

  MonthlySale({
    required this.month,
    required this.total,
    required this.deliveryFee,
    required this.tax,
    required this.subTotal,
  });

  factory MonthlySale.fromJson(Map<String, dynamic> json) {
    return MonthlySale(
      month: json['month'],
      total: json['total'],
      deliveryFee: json['deliveryFee'],
      tax: json['tax'],
      subTotal: json['subTotal'],
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
  final int saleUserId;
  final String total;
  final String deliveryFee;
  final String tax;
  final String subTotal;

  MonthlyTopSaleUser({
    this.saleFirstName,
    this.saleLastName,
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
      saleEmail: json['saleemail'],
      saleUserId: json['saleuserid'],
      total: json['total'],
      deliveryFee: json['deliveryFee'],
      tax: json['tax'],
      subTotal: json['subTotal'],
    );
  }
}
