import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/refund.dart';

class RefundAsyncNotifier extends AsyncNotifier<List<Refund>> {
  final DioService _dio = DioService();

  @override
  Future<List<Refund>> build() async {
    return await fetchRefunds();
  }

  // ================= FETCH ALL REFUNDS =================
  Future<List<Refund>> fetchRefunds({int page = 1, int limit = 10}) async {
    final url = "v1/refunds";

    final response = await _dio.get(url, query: {"page": page, "limit": limit});
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final List items = data["data"];

      return items.map((json) => Refund.fromJson(json)).toList();
    }

    throw Exception("Failed to fetch refunds");
  }

  // ================= CREATE REFUND =================
  Future<bool> createRefund(Map<String, dynamic> body) async {
    final url = "v1/refunds";

    final response = await _dio.post(url, data: body);

    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      // 🔥 Refresh list after create
      await refreshRefunds();
      return true;
    }

    throw Exception("Failed to create refund");
  }

  // ================= REFRESH =================
  Future<void> refreshRefunds() async {
    state = const AsyncLoading();

    try {
      final refunds = await fetchRefunds();
      state = AsyncData(refunds);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

final refundProvider = AsyncNotifierProvider<RefundAsyncNotifier, List<Refund>>(
  RefundAsyncNotifier.new,
);
