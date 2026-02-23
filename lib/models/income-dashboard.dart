import 'package:pos/models/income-summary.dart';
import 'package:pos/models/sale-item.dart';

class IncomeDashboard {
  final IncomeSummary summary;
  final SaleItem mostSaleItem;
  final SaleItem leastSaleItem;

  IncomeDashboard({
    required this.summary,
    required this.mostSaleItem,
    required this.leastSaleItem,
  });

  factory IncomeDashboard.fromJson(Map<String, dynamic> json) {
    return IncomeDashboard(
      summary: IncomeSummary.fromJson(json['summary']),
      mostSaleItem: SaleItem.fromJson(json['mostSaleItem']),
      leastSaleItem: SaleItem.fromJson(json['leastSaleItem']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'mostSaleItem': mostSaleItem.toJson(),
      'leastSaleItem': leastSaleItem.toJson(),
    };
  }
}
