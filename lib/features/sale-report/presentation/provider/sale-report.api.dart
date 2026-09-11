import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/core/provider.dart';
import 'package:pos/features/sale-report/data/model/sale-report.dart';

class SaleReportAsyncNotifier extends AsyncNotifier<SaleReport> {
  late DioService _dio;

  @override
  Future<SaleReport> build() async {
    _dio = ref.watch(dioServiceProvider);
    return await _fetchOpeningAndClosing();
  }

  /// -------- GET Opening & Closing Report --------
  Future<SaleReport> _fetchOpeningAndClosing({DateTime? date}) async {
    final queryDate = date != null
        ? date.toIso8601String().substring(0, 10)
        : DateTime.now().toIso8601String().substring(0, 10);
    final url = "v1/sale-reports/opening/amount";

    final response = await _dio.get(url, query: {"date": date ?? queryDate});
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final items = data["data"];
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

  Future<bool> postTransfer({
    required int from,
    required int to,
    required double amount,
    required String date,
    required String transferType,
  }) async {
    final url = "v1/sale-reports/transfer";

    final response = await _dio.post(
      url,
      data: {
        "from": from,
        "to": to,
        "amount": amount,
        "date": date,
        "transferType": transferType,
      },
    );
    final Map<String, dynamic> data = response.data;
    print("Response from posting transfer: $data");
    if (data["success"] == true) {
      return data["success"];
    }

    throw Exception("Failed to post transfer");
  }

  Future<List<Transfer>> getAllTransfers(String date) async {
    final response = await _dio.get(
      "v1/sale-reports/transfer/all",
      query: {"date": date},
    );
    final Map<String, dynamic> data = response.data;
    if (data["success"] == true) {
      final List list = data["data"];
      return list.map((e) => Transfer.fromJson(e)).toList();
    }
    throw Exception("Failed to fetch transfers");
  }

  Future<bool> deleteTransfer(int id) async {
    final response = await _dio.delete("v1/sale-reports/transfer/$id");
    final Map<String, dynamic> data = response.data;
    if (data["success"] == true) {
      return true;
    }
    throw Exception("Failed to delete transfer");
  }

  /// -------- Refresh opening/closing report (pull-to-refresh, post-transfer, etc.) --------
  Future<void> refreshAccount({DateTime? date}) async {
    try {
      final report = await _fetchOpeningAndClosing(date: date);
      state = AsyncData(report);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  /// -------- Refresh transfer list for a given date --------
  void refreshTransfer(String date) {
    ref.invalidate(transferListProvider(date));
  }

  Future<List<SaleReportEntry>> getAllSaleReports(String date) async {
    final response = await _dio.get("v1/sale-reports", query: {"date": date});
    final Map<String, dynamic> data = response.data;
    if (data["success"] == true) {
      final List list = data["data"];
      return list.map((e) => SaleReportEntry.fromJson(e)).toList();
    }
    throw Exception("Failed to fetch sale report entries");
  }

  Future<bool> deleteSaleReportEntry(int id) async {
    final response = await _dio.delete("v1/sale-reports/$id");
    final Map<String, dynamic> data = response.data;
    if (data["success"] == true) {
      return true;
    }
    throw Exception("Failed to delete sale report entry");
  }

  /// -------- Refresh sale report entry list for a given date --------
  void refreshSaleReportEntries(String date) {
    ref.invalidate(saleReportListProvider(date));
  }
}

final saleReportProvider =
    AsyncNotifierProvider<SaleReportAsyncNotifier, SaleReport>(
      SaleReportAsyncNotifier.new,
    );

final transferListProvider = FutureProvider.family<List<Transfer>, String>((
  ref,
  date,
) async {
  return ref.read(saleReportProvider.notifier).getAllTransfers(date);
});

final saleReportListProvider =
    FutureProvider.family<List<SaleReportEntry>, String>((ref, date) async {
      return ref.read(saleReportProvider.notifier).getAllSaleReports(date);
    });
