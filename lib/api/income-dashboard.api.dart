import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/dashboard-stats.dart';

class IncomeAsyncNotifier extends AsyncNotifier<DashboardStats> {
  final DioService _dio = DioService();

  @override
  Future<DashboardStats> build() async {
    // Initial load (today)
    return _fetchIncome();
  }

  /// 🔹 Private fetch method (returns data)
  Future<DashboardStats> _fetchIncome({DateTime? date}) async {
    final url = "v1/incomes";

    final queryDate = date != null
        ? date.toIso8601String().substring(0, 10)
        : DateTime.now().toIso8601String().substring(0, 10);

    print("queryDate 🧚 $queryDate");

    final response = await _dio.get(url, query: {"date": queryDate});

    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final items = data["data"];
      return DashboardStats.fromJson(items);
    }

    throw Exception("Failed to fetch income");
  }

  /// 🔹 Public method (updates state)
  Future<void> getIncomesByCompany({DateTime? date}) async {
    state = const AsyncLoading();

    try {
      final income = await _fetchIncome(date: date);
      state = AsyncData(income);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

/// Provider
final incomeProvider =
    AsyncNotifierProvider<IncomeAsyncNotifier, DashboardStats>(
      IncomeAsyncNotifier.new,
    );
