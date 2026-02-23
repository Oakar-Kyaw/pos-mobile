import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/payment-data.dart';

class PaymentDataAsyncNotifier extends AsyncNotifier<List<PaymentData>> {
  final DioService _dio = DioService();

  @override
  Future<List<PaymentData>> build() async {
    return await getPaymentDataByUserId();
  }

  /// -------- GET ALL PAYMENT DATA --------
  Future<List<PaymentData>> getPaymentDataByUserId() async {
    final url = "v1/payment-data";
    final response = await _dio.get(url);
    final Map<String, dynamic> data = response.data;

    // print("payment data: 📊: $data");
    if (data["success"] == true) {
      final items = data["data"] as List;

      List<PaymentData> paymentList = items
          .map((e) => PaymentData.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return paymentList;
    }

    throw Exception("Failed to fetch payment data");
  }

  /// -------- CREATE PAYMENT DATA --------
  Future<bool> postPaymentData(Map<String, dynamic> json) async {
    final url = "v1/payment-data";
    final response = await _dio.post(url, data: json);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      // Optional: refresh list automatically
      state = const AsyncLoading();
      state = AsyncData(await getPaymentDataByUserId());
      return true;
    }

    throw Exception("Failed to create payment data");
  }

  /// -------- UPDATE PAYMENT DATA --------
  Future<bool> updatePaymentData(int id, Map<String, dynamic> json) async {
    final url = "v1/payment-data/$id";
    final response = await _dio.patch(url, data: json);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      state = const AsyncLoading();
      state = AsyncData(await getPaymentDataByUserId());
      return true;
    }

    throw Exception("Failed to update payment data");
  }

  /// -------- DELETE PAYMENT DATA --------
  Future<bool> deletePaymentData(int id) async {
    final url = "v1/payment-data/$id";
    final response = await _dio.delete(url);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      state = const AsyncLoading();
      state = AsyncData(await getPaymentDataByUserId());
      return true;
    }

    throw Exception("Failed to delete payment data");
  }
}

final paymentDataProvider =
    AsyncNotifierProvider<PaymentDataAsyncNotifier, List<PaymentData>>(
      PaymentDataAsyncNotifier.new,
    );
