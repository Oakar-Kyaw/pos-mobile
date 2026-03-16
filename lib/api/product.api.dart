import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/inventory-management.dart';
import 'package:pos/models/product.dart';

class ProductAsyncNotifier extends AsyncNotifier<List<Product>> {
  final DioService _dio = DioService();

  @override
  Future<List<Product>> build() async {
    // Provide default values or initial values
    return await getProductByUserId("1", "20");
  }

  Future<List<Product>> getProductByUserId(
    String page,
    String limit, {
    String? search,
  }) async {
    state = const AsyncLoading();
    try {
      final url = "v1/products";
      final response = await _dio.get(
        url,
        query: {"page": page, "limit": limit, "search": search},
      );
      final Map<String, dynamic> data = response.data;
      //print("data 👨‍🏭 $data");
      if (data["success"] == true) {
        final items = data["data"] as List;
        List<Product> products = items
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        state = AsyncData(products);
        return products;
      } else {
        state = AsyncError("Failed to fetch products", StackTrace.current);
        throw Exception("Failed to fetch");
      }
    } catch (e, st) {
      //print("FAi $e");
      state = AsyncError(e, st);
      throw Exception("Failed to fetch");
    }
  }

  Future<bool> postProduct(FormData json) async {
    final url = "v1/products";
    _dio.setContentType("multipart/form-data");
    final response = await _dio.post(url, data: json);
    final Map<String, dynamic> data = response.data;
    print("🤩 data is $data");

    if (data["success"] == true) {
      // Optionally refresh the product list after posting
      ref.invalidateSelf();
      return true;
    }

    throw Exception("Failed to post product");
  }

  Future<void> searchProducts({required String search}) async {
    state = const AsyncLoading();

    try {
      final proudct = await getProductByUserId("1", "20", search: search);
      state = AsyncData(proudct);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final products = await getProductByUserId("1", "20");
      state = AsyncData(products);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  /// -------- CREATE expire/damage and request --------
  Future<Map<String, dynamic>> createInventory({
    required Map<String, dynamic> body,
  }) async {
    final url = "v1/products/expire-items";

    final response = await _dio.post(url, data: body);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      // Refresh the list automatically
      // state = const AsyncLoading();
      // state = AsyncData(await getVouchers());
      return {"success": true, "id": data["data"]["id"]};
    }

    throw Exception("Failed to create repayment");
  }

  /// -------- Get Expire / Damage / Request List --------
  Future<List<InventoryManagement>> getExpireDamageRequestList({
    required int page,
    required int limit,
    required String type,
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final url = "v1/products/inventory/list";

    final response = await _dio.get(
      url,
      query: {
        "page": page,
        "limit": limit,
        "type": type,
        if (userId != null) "filterUserId": userId,
        if (startDate != null) "startDate": startDate.toIso8601String(),
        if (endDate != null) "endDate": endDate.toIso8601String(),
      },
    );
    final data = response.data;

    if (data["success"] == true) {
      // Refresh the list automatically
      return InventoryManagement.listFromJson(data["data"]);
    }

    throw Exception("Failed to get inventory item");
  }

  /// -------- Delete Expire / Damage / Request --------
  Future<bool> deleteInventoryManagement(int id) async {
    final url = "v1/products/inventory/list/$id";
    final response = await _dio.delete(url);
    final data = response.data;

    if (data["success"] == true) {
      return true;
    }

    throw Exception(data["message"] ?? "Failed to delete inventory item");
  }
}

final productProvider =
    AsyncNotifierProvider<ProductAsyncNotifier, List<Product>>(
      () => ProductAsyncNotifier(),
    );
