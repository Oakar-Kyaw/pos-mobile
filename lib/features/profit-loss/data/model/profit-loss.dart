class ProfitAndLoss {
  final ProfitAndLossSummary todayProfitAndLoss;
  final ProfitAndLossSummary monthlyProfitAndLoss;
  final ProfitAndLossSummary yearlyProfitAndLoss;
  final List<ItemProfitAndLoss> todayItemProfitAndLoss;
  final List<ItemProfitAndLoss> monthlyItemProfitAndLoss;
  final List<ItemProfitAndLoss> yearlyItemProfitAndLoss;

  ProfitAndLoss({
    required this.todayProfitAndLoss,
    required this.monthlyProfitAndLoss,
    required this.yearlyProfitAndLoss,
    required this.todayItemProfitAndLoss,
    required this.monthlyItemProfitAndLoss,
    required this.yearlyItemProfitAndLoss,
  });

  factory ProfitAndLoss.fromJson(Map<String, dynamic> json) {
    return ProfitAndLoss(
      todayProfitAndLoss: ProfitAndLossSummary.fromJson(
        json['todayProfitAndLoss'] ?? {},
      ),
      monthlyProfitAndLoss: ProfitAndLossSummary.fromJson(
        json['monthlyProfitAndLoss'] ?? {},
      ),
      yearlyProfitAndLoss: ProfitAndLossSummary.fromJson(
        json['yearlyProfitAndLoss'] ?? {},
      ),
      todayItemProfitAndLoss: (json['todayItemProfitAndLoss'] as List? ?? [])
          .map((e) => ItemProfitAndLoss.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      monthlyItemProfitAndLoss:
          (json['monthlyItemProfitAndLoss'] as List? ?? [])
              .map(
                (e) => ItemProfitAndLoss.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(),
      yearlyItemProfitAndLoss: (json['yearlyItemProfitAndLoss'] as List? ?? [])
          .map((e) => ItemProfitAndLoss.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayProfitAndLoss': todayProfitAndLoss.toJson(),
      'monthlyProfitAndLoss': monthlyProfitAndLoss.toJson(),
      'yearlyProfitAndLoss': yearlyProfitAndLoss.toJson(),
      'todayItemProfitAndLoss': todayItemProfitAndLoss
          .map((e) => e.toJson())
          .toList(),
      'monthlyItemProfitAndLoss': monthlyItemProfitAndLoss
          .map((e) => e.toJson())
          .toList(),
      'yearlyItemProfitAndLoss': yearlyItemProfitAndLoss
          .map((e) => e.toJson())
          .toList(),
    };
  }
}

class ProfitAndLossSummary {
  final double grossRevenue;
  final double cogs;
  final double refundRevenue;
  final double refundCogs;
  final double netSales;
  final double netCogs;
  final double grossProfit;
  final double operatingExpense;
  final double wastageAmount;
  final double netProfit;
  final double grossMarginPercent;
  final double netMarginPercent;

  ProfitAndLossSummary({
    required this.grossRevenue,
    required this.cogs,
    required this.refundRevenue,
    required this.refundCogs,
    required this.netSales,
    required this.netCogs,
    required this.grossProfit,
    required this.operatingExpense,
    required this.wastageAmount,
    required this.netProfit,
    required this.grossMarginPercent,
    required this.netMarginPercent,
  });

  factory ProfitAndLossSummary.fromJson(Map<String, dynamic> json) {
    return ProfitAndLossSummary(
      grossRevenue: _toDouble(json['grossRevenue']),
      cogs: _toDouble(json['cogs']),
      refundRevenue: _toDouble(json['refundRevenue']),
      refundCogs: _toDouble(json['refundCogs']),
      netSales: _toDouble(json['netSales']),
      netCogs: _toDouble(json['netCogs']),
      grossProfit: _toDouble(json['grossProfit']),
      operatingExpense: _toDouble(json['operatingExpense']),
      wastageAmount: _toDouble(json['wastageAmount']),
      netProfit: _toDouble(json['netProfit']),
      grossMarginPercent: _toDouble(json['grossMarginPercent']),
      netMarginPercent: _toDouble(json['netMarginPercent']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grossRevenue': grossRevenue,
      'cogs': cogs,
      'refundRevenue': refundRevenue,
      'refundCogs': refundCogs,
      'netSales': netSales,
      'netCogs': netCogs,
      'grossProfit': grossProfit,
      'operatingExpense': operatingExpense,
      'wastageAmount': wastageAmount,
      'netProfit': netProfit,
      'grossMarginPercent': grossMarginPercent,
      'netMarginPercent': netMarginPercent,
    };
  }
}

class ItemProfitAndLoss {
  final int productId;
  final String name;
  final String photoUrl;
  final int soldQty;
  final double revenue;
  final double cogs;
  final double refundedRevenue;
  final double refundedCogs;
  final double wastageAmount;
  final double netSales;
  final double netCogs;
  final double grossProfit;
  final double netProfit;
  final double grossMarginPercent;
  final double netMarginPercent;

  ItemProfitAndLoss({
    required this.productId,
    required this.name,
    required this.photoUrl,
    required this.soldQty,
    required this.revenue,
    required this.cogs,
    required this.refundedRevenue,
    required this.refundedCogs,
    required this.wastageAmount,
    required this.netSales,
    required this.netCogs,
    required this.grossProfit,
    required this.netProfit,
    required this.grossMarginPercent,
    required this.netMarginPercent,
  });

  factory ItemProfitAndLoss.fromJson(Map<String, dynamic> json) {
    return ItemProfitAndLoss(
      productId: _toInt(json['productId']),
      name: json['name'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      soldQty: _toInt(json['soldQty']),
      revenue: _toDouble(json['revenue']),
      cogs: _toDouble(json['cogs']),
      refundedRevenue: _toDouble(json['refundedRevenue']),
      refundedCogs: _toDouble(json['refundedCogs']),
      wastageAmount: _toDouble(json['wastageAmount']),
      netSales: _toDouble(json['netSales']),
      netCogs: _toDouble(json['netCogs']),
      grossProfit: _toDouble(json['grossProfit']),
      netProfit: _toDouble(json['netProfit']),
      grossMarginPercent: _toDouble(json['grossMarginPercent']),
      netMarginPercent: _toDouble(json['netMarginPercent']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'photoUrl': photoUrl,
      'soldQty': soldQty,
      'revenue': revenue,
      'cogs': cogs,
      'refundedRevenue': refundedRevenue,
      'refundedCogs': refundedCogs,
      'wastageAmount': wastageAmount,
      'netSales': netSales,
      'netCogs': netCogs,
      'grossProfit': grossProfit,
      'netProfit': netProfit,
      'grossMarginPercent': grossMarginPercent,
      'netMarginPercent': netMarginPercent,
    };
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value.toString()) ?? 0;
}
