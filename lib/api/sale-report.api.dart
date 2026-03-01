import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/sale-report.dart';

class SaleReportAsyncNotifier extends AsyncNotifier<SaleReport> {
  final DioService _dio = DioService();

  @override
  Future<SaleReport> build() async {
    return await _fetchOpeningAndClosing();
  }

  /// -------- GET Opening & Closing Report --------
  Future<SaleReport> _fetchOpeningAndClosing({DateTime? date}) async {
    // Use today as default
    final queryDate = date != null
        ? date.toIso8601String().substring(0, 10)
        : DateTime.now().toIso8601String().substring(0, 10);
    final url = "v1/sale-reports/opening/amount";

    final response = await _dio.get(url, query: {"date": date ?? queryDate});
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final items = data["data"];
      //print("success 😇 $items");
      SaleReport report = SaleReport.fromJson(items);
      return report;
    }

    throw Exception("Failed to fetch sale report");
  }

  Future<bool> postOpeningAndClosingBalance({
    required String date,
    required double total,
    String description = "",
  }) async {
    // Use today as default
    final url = "v1/sale-reports";

    final response = await _dio.post(
      url,
      data: {"date": date, "amount": total, "description": description},
    );
    final Map<String, dynamic> data = response.data;
    print("Response from posting sale report: $data");
    if (data["success"] == true) {
      return data["success"];
    }

    throw Exception("Failed to post sale report");
  }

  Future<void> getOpenClosing({DateTime? date}) async {
    state = const AsyncLoading();

    try {
      final income = await _fetchOpeningAndClosing(date: date);
      state = AsyncData(income);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

final saleReportProvider =
    AsyncNotifierProvider<SaleReportAsyncNotifier, SaleReport>(
      SaleReportAsyncNotifier.new,
    );
