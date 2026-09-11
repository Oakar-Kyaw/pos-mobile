import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/core/provider.dart';
import 'package:pos/features/profit-loss/data/model/profit-loss.dart';

class ProfitAndLossAsyncNotifier extends AsyncNotifier<ProfitAndLoss> {
  late DioService _dio;

  @override
  Future<ProfitAndLoss> build() async {
    _dio = ref.watch(dioServiceProvider);

    // Initial load (today)
    return _fetchProfitAndLoss();
  }

  /// 🔹 Private fetch method
  Future<ProfitAndLoss> _fetchProfitAndLoss({DateTime? date}) async {
    const url = "v1/incomes/profit/loss";

    final queryDate = date != null
        ? date.toIso8601String().substring(0, 10)
        : DateTime.now().toIso8601String().substring(0, 10);

    print("Profit & Loss queryDate 🧚 $queryDate");

    final response = await _dio.get(url, query: {"date": queryDate});

    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      return ProfitAndLoss.fromJson(data);
    }

    throw Exception(data["message"] ?? "Failed to fetch profit and loss");
  }

  /// 🔹 Public method
  /// Updates the provider state with selected date data.
  Future<void> getProfitAndLoss({DateTime? date}) async {
    state = const AsyncLoading();

    try {
      final profitAndLoss = await _fetchProfitAndLoss(date: date);

      state = AsyncData(profitAndLoss);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

/// Provider
final profitAndLossProvider =
    AsyncNotifierProvider<ProfitAndLossAsyncNotifier, ProfitAndLoss>(
      ProfitAndLossAsyncNotifier.new,
    );
