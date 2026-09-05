import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/core/provider.dart';
import 'package:pos/models/inventory-management.dart';
import 'package:pos/models/product.dart';

class ProductAsyncNotifier extends AsyncNotifier<List<Product>> {
  late DioService _dio;

  @override
  Future<List<Product>> build() async {
    // Provide default values or initial values
    _dio = ref.watch(dioServiceProvider);
    return await getProductLists("1", "20");
  }

  Future<List<Product>> getProductLists(
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
      print("data 👨‍🏭 $data");
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
    // print("Post Product is 🐹 $json");
    final response = await _dio.post(url, data: json);
    final Map<String, dynamic> data = response.data;
    // print("🤩 data is $data");

    if (data["success"] == true) {
      // Optionally refresh the product list after posting
      ref.invalidateSelf();
      return true;
    }

    throw Exception("Failed to post product");
  }

  Future<bool> editProductById(int id, FormData json) async {
    final url = "v1/products/$id";
    _dio.setContentType("multipart/form-data");
    // for (final field in json.fields) {
    //   print("${field.key}: ${field.value}");
    // }

    // for (final file in json.files) {
    //   print("${file.key}: ${file.value.filename}, ${file.value.contentType}");
    // }
    final response = await _dio.patch(url, data: json);
    final Map<String, dynamic> data = response.data;
    // print("🤩 data is $data");

    if (data["success"] == true) {
      // Optionally refresh the product list after posting
      ref.invalidateSelf();
      return true;
    }

    throw Exception("Failed to edit product");
  }

  Future<void> searchProducts({required String search}) async {
    state = const AsyncLoading();

    try {
      final proudct = await getProductLists("1", "20", search: search);
      state = AsyncData(proudct);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<Product> searchProductsByBarcode({required String barcode}) async {
    try {
      final url = "v1/products/barcode/$barcode";

      final response = await _dio.get(url);
      final Map<String, dynamic> data = response.data;
      print("product by barcode is 📱 $data");
      if (data["success"] == true) {
        return Product.fromJson(Map<String, dynamic>.from(data["data"]));
      }

      throw Exception(data["message"] ?? "Product not found");
    } catch (e) {
      throw Exception("Failed to fetch product: $e");
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final products = await getProductLists("1", "20");
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

  /// -------- Get Expire / Damage / Request List --------
  Future<bool> confirmInventoryRecordItem({required int index}) async {
    final url = "v1/products/expire-items/$index/confirm";

    final response = await _dio.patch(url);
    final data = response.data;
    if (data["success"] == true) {
      // Refresh the list automatically
      // ref.invalidateSelf();
      return true;
    }

    throw Exception("Failed to confirm inventory item");
  }

  /// -------- UPDATE expire/damage and request --------
  Future<Map<String, dynamic>> updateInventoryManagement({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    final url = "v1/products/expire-items/$id";

    final response = await _dio.patch(url, data: body);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      return {"success": true, "id": data["data"]["id"]};
    }

    throw Exception(data["message"] ?? "Failed to update inventory item");
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
