import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/core/provider.dart';
import 'package:pos/features/brand/data/model/brand.dart'; // 👈 Brand model ရဲ့ တကယ့် path အတိုင်း ချိန်ညှိပါ

class BrandAsyncNotifier extends AsyncNotifier<List<Brand>> {
  late DioService _dio;

  @override
  Future<List<Brand>> build() async {
    _dio = ref.watch(dioServiceProvider);
    return await getBrandByUserId();
  }

  Future<List<Brand>> getBrandByUserId() async {
    final url = "v1/brands";
    final response = await _dio.get(url);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final items = data["data"] as List;
      List<Brand> brands = items
          .map((e) => Brand.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return brands;
    }

    throw Exception("Failed to fetch brand");
  }

  Future<bool> postBrand(Map<String, dynamic> json) async {
    final url = "v1/brands";
    final response = await _dio.post(url, data: json);
    final Map<String, dynamic> data = response.data;
    print("🤩 data is $data");
    if (data["success"] && data["success"] == true) {
      return true;
    }

    throw Exception("Failed to post");
  }

  Future<bool> updateBrand({
    required int id,
    required Map<String, dynamic> json,
  }) async {
    final url = "v1/brands/$id";
    final response = await _dio.patch(url, data: json);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      return true;
    }

    throw Exception("Failed to update brand");
  }

  Future<bool> deleteBrand(int id) async {
    final url = "v1/brands/$id";
    final response = await _dio.delete(url);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      return true;
    }

    throw Exception("Failed to delete brand");
  }
}

final brandProvider = AsyncNotifierProvider(BrandAsyncNotifier.new);
