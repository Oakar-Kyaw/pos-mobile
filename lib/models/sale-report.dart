class SaleReport {
  final double? openingAmount;
  final double? closingAmount;
  final bool isClosed;

  SaleReport({
    required this.openingAmount,
    required this.closingAmount,
    required this.isClosed,
  });

  factory SaleReport.fromJson(Map<String, dynamic> json) {
    return SaleReport(
      openingAmount: json['openingAmount'] != null
          ? double.parse(json['openingAmount'].toString())
          : null,
      closingAmount: json['closingAmount'] != null
          ? double.parse(json['closingAmount'].toString())
          : null,
      isClosed: json['isClosed'] ?? false,
    );
  }
}
