import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/account.dart';
import 'package:pos/models/payment-data.dart';

class PaymentDataAsyncNotifier extends AsyncNotifier<List<PaymentData>> {
  final DioService _dio = DioService();

  @override
  Future<List<PaymentData>> build() async {
    return await fetchAccounts();
  }

  /// -------- GET All Accounts (Optional pagination) --------
  Future<List<PaymentData>> fetchAccounts({
    int page = 1,
    int limit = 10,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};

    final response = await _dio.get("v1/payment-data", query: query);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final items = data["data"] as List<dynamic>;
      return items
          .map((e) => PaymentData.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Failed to fetch accounts");
  }

  /// -------- GET Single Account --------
  Future<PaymentData> fetchAccountById(int id) async {
    final response = await _dio.get("v1/payment-data/$id");
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      return PaymentData.fromJson(data["data"]);
    }

    throw Exception("Failed to fetch account");
  }

  /// -------- POST Create Account --------
  Future<bool> createAccount({
    String? accountNumber,
    required String accountName,
    required String accountType,
    required double balance,
    required bool isActive,
  }) async {
    final payload = {
      if (accountNumber != null) 'accountNumber': accountNumber,
      'accountName': accountName,
      'accountType': accountType,
      'balance': balance,
      'isActive': isActive,
    };

    final response = await _dio.post("v1/payment-data", data: payload);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) return true;
    throw Exception("Failed to create account");
  }

  /// -------- PATCH Update Account --------
  Future<bool> updateAccount({
    required int id,
    String? accountNumber,
    String? accountName,
    String? accountType,
    double? balance,
    bool? isActive,
  }) async {
    final payload = <String, dynamic>{
      if (accountNumber != null) 'accountNumber': accountNumber,
      if (accountName != null) 'accountName': accountName,
      if (accountType != null) 'accountType': accountType,
      if (isActive != null) 'isActive': isActive,
      'balance': balance ?? 0,
    };

    final response = await _dio.patch("v1/payment-data/$id", data: payload);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      return true;
    }

    throw Exception("Failed to update account");
  }

  /// -------- DELETE Account (Soft Delete) --------
  Future<bool> deleteAccount(int id) async {
    final response = await _dio.delete("v1/payment-data/$id");
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) return true;
    throw Exception("Failed to delete account");
  }

  /// -------- Refresh State --------
  Future<void> refreshAccounts({int page = 1, int limit = 10}) async {
    state = const AsyncLoading();

    try {
      final accounts = await fetchAccounts(page: page, limit: limit);
      state = AsyncData(accounts);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

/// 🚀 Provider
final paymentDataProvider =
    AsyncNotifierProvider<PaymentDataAsyncNotifier, List<PaymentData>>(
      PaymentDataAsyncNotifier.new,
    );
