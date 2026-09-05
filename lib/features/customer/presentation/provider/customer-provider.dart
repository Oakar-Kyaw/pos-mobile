import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/core/provider.dart';
import 'package:pos/features/customer/data/model/customer-model.dart';

class CustomerAsyncNotifier extends AsyncNotifier<List<Customer>> {
  late DioService _dio;

  @override
  Future<List<Customer>> build() async {
    _dio = ref.watch(dioServiceProvider);

    return await getCustomerLists(page: 1, limit: 20);
  }

  // ==========================================
  // GET CUSTOMER LIST
  // ==========================================

  Future<List<Customer>> getCustomerLists({
    required int page,
    required int limit,
    String? search,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await _dio.get(
        "v1/customers",
        query: {
          "page": page,
          "limit": limit,
          if (search != null && search.isNotEmpty) "search": search,
        },
      );

      final data = response.data;

      if (data["success"] == true) {
        final customers = Customer.listFromJson(data["data"]);

        state = AsyncData(customers);

        return customers;
      }

      throw Exception(data["message"] ?? "Failed to fetch customers");
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // ==========================================
  // GET CUSTOMER BY ID
  // ==========================================

  Future<Customer> getCustomerById(int id) async {
    try {
      final response = await _dio.get("v1/customers/$id");

      final data = response.data;

      if (data["success"] == true) {
        return Customer.fromJson(data["data"]);
      }

      throw Exception(data["message"] ?? "Customer not found");
    } catch (e) {
      rethrow;
    }
  }

  // ==========================================
  // CREATE CUSTOMER
  // ==========================================

  Future<bool> createCustomer(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post("v1/customers", data: body);

      final data = response.data;

      if (data["success"] == true) {
        ref.invalidateSelf();
        return true;
      }

      throw Exception(data["message"] ?? "Failed to create customer");
    } catch (e) {
      rethrow;
    }
  }

  // ==========================================
  // UPDATE CUSTOMER
  // ==========================================

  Future<bool> updateCustomer(int id, Map<String, dynamic> body) async {
    try {
      final response = await _dio.patch("v1/customers/$id", data: body);

      final data = response.data;

      if (data["success"] == true) {
        ref.invalidateSelf();
        return true;
      }

      throw Exception(data["message"] ?? "Failed to update customer");
    } catch (e) {
      rethrow;
    }
  }

  // ==========================================
  // DELETE CUSTOMER
  // ==========================================

  Future<bool> deleteCustomer(int id) async {
    try {
      final response = await _dio.delete("v1/customers/$id");

      final data = response.data;

      if (data["success"] == true) {
        ref.invalidateSelf();
        return true;
      }

      throw Exception(data["message"] ?? "Failed to delete customer");
    } catch (e) {
      rethrow;
    }
  }

  // ==========================================
  // SEARCH CUSTOMERS
  // ==========================================

  Future<List<Customer>> searchCustomers({required String search}) async {
    try {
      final response = await _dio.get("v1/customers/filter?search=$search");

      final data = response.data;

      if (data["success"] == true) {
        final customers = Customer.listFromJson(data["data"]);
        return customers;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  // ==========================================
  // REFRESH CUSTOMERS
  // ==========================================

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final customers = await getCustomerLists(page: 1, limit: 20);

      state = AsyncData(customers);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// ==========================================
// PROVIDER
// ==========================================

final customerProvider =
    AsyncNotifierProvider<CustomerAsyncNotifier, List<Customer>>(
      () => CustomerAsyncNotifier(),
    );
