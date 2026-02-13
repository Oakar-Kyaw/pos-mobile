import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/category.dart';

class CategoryAsyncNotifier extends AsyncNotifier<List<Category>> {
  final DioService _dio = DioService();
  @override
  Future<List<Category>> build() async {
    return await getCategoryByUserId();
  }

  Future<List<Category>> getCategoryByUserId() async {
    final url = "v1/category";
    final response = await _dio.get(url);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final items = data["data"] as List;
      List<Category> categories = items
          .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return categories;
    }

    throw Exception("Failed to fetch category");
  }

  Future<bool> postCategory(Map<String, dynamic> json) async {
    final url = "v1/category";
    final response = await _dio.post(url, data: json);
    final Map<String, dynamic> data = response.data;
    print("🤩 data is $data");
    if (data["success"] && data["success"] == true) {
      return true;
    }

    throw Exception("Failed to post");
  }
}

final categoryProvider = AsyncNotifierProvider(CategoryAsyncNotifier.new);
