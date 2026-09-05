import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/core/provider.dart';
import 'package:pos/features/purchase-history/data/model/purchase.dart';

class PurchaseAsyncNotifier extends AsyncNotifier<List<Purchase>> {
  late DioService _dio;

  @override
  Future<List<Purchase>> build() async {
    _dio = ref.watch(dioServiceProvider);
    return await getPurchaseLists(page: 1, limit: 20);
  }

  Future<List<Purchase>> getPurchaseLists({
    required int page,
    required int limit,

    String? search,
    int? supplierId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncLoading();
    //if filter is true then search api
    final hasFilter =
        search != null ||
        supplierId != null ||
        status != null ||
        startDate != null ||
        endDate != null;

    final url = hasFilter ? "v1/purchases/filter" : "v1/purchases";
    try {
      print("get purchase history 🖨️ $startDate $endDate $hasFilter");
      final response = await _dio.get(
        url,
        query: {
          "page": page,
          "limit": limit,
          if (search != null) "search": search,
          if (supplierId != null) "supplierId": supplierId,
          if (status != null) "status": status,
          if (startDate != null) "startDate": startDate.toIso8601String(),
          if (endDate != null) "endDate": endDate.toIso8601String(),
        },
      );

      final data = response.data;

      print("RESPONSE:🧠 ${response.data}");

      if (data["success"] == true) {
        final purchases = Purchase.listFromJson(data["data"]);

        state = AsyncData(purchases);

        return purchases;
      }

      throw Exception(data["message"] ?? "Failed to fetch purchases");
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> createPurchase(Map<String, dynamic> body) async {
    debugPrint("create purchase ");
    final response = await _dio.post("v1/purchases", data: body);
    print("create purchase is $response");
    final data = response.data;

    if (data["success"] == true) {
      ref.invalidateSelf();
      return true;
    }

    throw Exception(data["message"] ?? "Failed to create purchase");
  }

  Future<bool> updatePurchase(int id, Map<String, dynamic> body) async {
    final response = await _dio.patch("v1/purchases/$id", data: body);

    final data = response.data;

    if (data["success"] == true) {
      ref.invalidateSelf();
      return true;
    }

    throw Exception(data["message"] ?? "Failed to update purchase");
  }

  Future<Purchase> getPurchaseById(int id) async {
    final response = await _dio.get("v1/purchases/$id");

    final data = response.data;

    if (data["success"] == true) {
      return Purchase.fromJson(data["data"]);
    }

    throw Exception(data["message"] ?? "Purchase not found");
  }

  Future<bool> deletePurchase(int id) async {
    final response = await _dio.delete("v1/purchases/$id");

    final data = response.data;

    if (data["success"] == true) {
      return true;
    }

    throw Exception(data["message"] ?? "Failed to delete purchase");
  }

  Future<void> searchPurchases({required String search}) async {
    state = const AsyncLoading();

    try {
      final purchases = await getPurchaseLists(
        page: 1,
        limit: 20,
        search: search,
      );

      state = AsyncData(purchases);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<bool> updateSucess(int id) async {
    final response = await _dio.patch("v1/purchases/confirm/$id");

    final data = response.data;

    if (data["success"] == true) {
      ref.invalidateSelf();
      return true;
    }

    throw Exception(data["message"] ?? "Failed to update purchase");
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final purchases = await getPurchaseLists(page: 1, limit: 20);

      state = AsyncData(purchases);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final purchaseProvider =
    AsyncNotifierProvider<PurchaseAsyncNotifier, List<Purchase>>(
      () => PurchaseAsyncNotifier(),
    );
