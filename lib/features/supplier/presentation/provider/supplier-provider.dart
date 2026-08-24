import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/core/provider.dart';
import 'package:pos/features/supplier/data/model/supplier.dart';

class SupplierAsyncNotifier extends AsyncNotifier<List<Supplier>> {
  late DioService _dio;

  @override
  Future<List<Supplier>> build() async {
    _dio = ref.watch(dioServiceProvider);

    return await getSupplierLists(page: 1, limit: 20);
  }

  Future<List<Supplier>> getSupplierLists({
    required int page,
    required int limit,
    String? search,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await _dio.get(
        "v1/suppliers",
        query: {
          "page": page,
          "limit": limit,
          if (search != null && search.isNotEmpty) "search": search,
        },
      );

      final data = response.data;

      if (data["success"] == true) {
        final suppliers = Supplier.listFromJson(data["data"]);

        state = AsyncData(suppliers);

        return suppliers;
      }

      throw Exception(data["message"] ?? "Failed to fetch suppliers");
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> createSupplier(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post("v1/suppliers", data: body);

      final data = response.data;

      if (data["success"] == true) {
        ref.invalidateSelf();
        return true;
      }

      throw Exception(data["message"] ?? "Failed to create supplier");
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateSupplier(int id, Map<String, dynamic> body) async {
    try {
      final response = await _dio.patch("v1/suppliers/$id", data: body);

      final data = response.data;

      if (data["success"] == true) {
        ref.invalidateSelf();
        return true;
      }

      throw Exception(data["message"] ?? "Failed to update supplier");
    } catch (e) {
      rethrow;
    }
  }

  Future<Supplier> getSupplierById(int id) async {
    final response = await _dio.get("v1/suppliers/$id");

    final data = response.data;

    if (data["success"] == true) {
      return Supplier.fromJson(data["data"]);
    }

    throw Exception(data["message"] ?? "Supplier not found");
  }

  Future<bool> deleteSupplier(int id) async {
    try {
      final response = await _dio.delete("v1/suppliers/$id");

      final data = response.data;

      if (data["success"] == true) {
        ref.invalidateSelf();
        return true;
      }

      throw Exception(data["message"] ?? "Failed to delete supplier");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> searchSuppliers({required String search}) async {
    state = const AsyncLoading();

    try {
      final suppliers = await getSupplierLists(
        page: 1,
        limit: 20,
        search: search,
      );

      state = AsyncData(suppliers);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final suppliers = await getSupplierLists(page: 1, limit: 20);

      state = AsyncData(suppliers);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final supplierProvider =
    AsyncNotifierProvider<SupplierAsyncNotifier, List<Supplier>>(
      () => SupplierAsyncNotifier(),
    );
