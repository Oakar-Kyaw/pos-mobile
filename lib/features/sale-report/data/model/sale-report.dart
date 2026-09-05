class SaleReport {
  final double openingAmount;
  final double closingAmount;
  final double totalPurchase;
  final double totalGeneralExpense;
  final bool isClosed;

  SaleReport({
    required this.openingAmount,
    required this.totalGeneralExpense,
    required this.totalPurchase,
    required this.closingAmount,
    required this.isClosed,
  });

  factory SaleReport.fromJson(Map<String, dynamic> json) {
    return SaleReport(
      openingAmount: double.parse(json['openingAmount'].toString()),
      closingAmount: double.parse(json['closingAmount'].toString()),
      totalGeneralExpense: double.parse(json['totalGeneralExpense'].toString()),
      totalPurchase: double.parse(json['totalPurchase'].toString()),
      isClosed: json['isClosed'] ?? false,
    );
  }
}
