import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/general-expense.dart';

class GeneralExpenseAsyncNotifier extends AsyncNotifier<List<GeneralExpense>> {
  final DioService _dio = DioService();

  @override
  Future<List<GeneralExpense>> build() async {
    return await fetchExpenses();
  }

  /// -------- GET All Expenses (Optional date filter + pagination) --------
  Future<List<GeneralExpense>> fetchExpenses({
    int page = 1,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };

    final response = await _dio.get("v1/general-expenses", query: query);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final items = data["data"] as List<dynamic>;
      return items
          .map((e) => GeneralExpense.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Failed to fetch general expenses");
  }

  /// -------- GET Single Expense --------
  Future<GeneralExpense> fetchExpenseById(int id) async {
    final response = await _dio.get("v1/general-expenses/$id");
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      return GeneralExpense.fromJson(data["data"]);
    }

    throw Exception("Failed to fetch general expense");
  }

  /// -------- POST Create Expense --------
  Future<bool> createExpense({
    required String title,
    String? reason,
    required double amount,
    required String date,
  }) async {
    final payload = {
      'title': title,
      if (reason != null) 'reason': reason,
      'amount': amount,
      'date': date,
    };

    final response = await _dio.post("v1/general-expenses", data: payload);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      return true;
    }

    throw Exception("Failed to create general expense");
  }

  /// -------- PATCH Update Expense --------
  Future<GeneralExpense> updateExpense({
    required int id,
    String? title,
    String? reason,
    double? amount,
    DateTime? date,
  }) async {
    final payload = <String, dynamic>{
      if (title != null) 'title': title,
      if (reason != null) 'reason': reason,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date.toIso8601String(),
    };

    final response = await _dio.patch("v1/general-expenses/$id", data: payload);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      return GeneralExpense.fromJson(data["data"]);
    }

    throw Exception("Failed to update general expense");
  }

  /// -------- DELETE Expense (Soft Delete) --------
  Future<bool> deleteExpense(int id) async {
    final response = await _dio.delete("v1/general-expenses/$id");
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      return true;
    }

    throw Exception("Failed to delete general expense");
  }

  /// -------- Refresh State --------
  Future<void> refreshExpenses({
    int page = 1,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncLoading();

    try {
      final expenses = await fetchExpenses(
        page: page,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
      state = AsyncData(expenses);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

/// 🚀 Provider
final generalExpenseProvider =
    AsyncNotifierProvider<GeneralExpenseAsyncNotifier, List<GeneralExpense>>(
      GeneralExpenseAsyncNotifier.new,
    );
