import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
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
}

final productProvider =
    AsyncNotifierProvider<ProductAsyncNotifier, List<Product>>(
      () => ProductAsyncNotifier(),
    );
