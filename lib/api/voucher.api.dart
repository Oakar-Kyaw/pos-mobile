import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class VoucherAsyncNotifier extends AsyncNotifier<List<VoucherDetailModel>> {
  final DioService _dio = DioService();

  @override
  Future<List<VoucherDetailModel>> build() async {
    return await getVouchersByUserId(page: 0, limit: 20);
  }

  /// -------- GET ALL VOUCHERS --------
  Future<List<VoucherDetailModel>> getVouchersByUserId({
    required int page,
    required int limit,
  }) async {
    final url = "v1/vouchers";
    final response = await _dio.get(url, query: {"page": page, "limit": limit});
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final items = data["data"] as List;
      List<VoucherDetailModel> vouchers = items
          .map((e) => VoucherDetailModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return vouchers;
    }

    throw Exception("Failed to fetch vouchers");
  }

  /// -------- GET BY ID VOUCHERS --------
  Future<VoucherDetailModel> getVoucherById(int id) async {
    final url = "v1/vouchers/$id";
    final response = await _dio.get(url);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final item = data["data"];
      VoucherDetailModel voucher = VoucherDetailModel.fromJson(
        Map<String, dynamic>.from(item),
      );

      return voucher;
    }

    throw Exception("Failed to fetch voucher by id");
  }

  /// -------- CREATE VOUCHER WITH FILES --------
  Future<Map<String, dynamic>> postVoucher({
    required VoucherDetailModel voucher,
    List<File>? files,
  }) async {
    final url = "v1/vouchers";

    // Convert items & payments to JSON
    final itemsJson = voucher.items.map((e) => e.toJson()).toList();
    final paymentsJson = voucher.payments.map((e) => e.toJson()).toList();

    // Convert files to MultipartFile
    List<MultipartFile> multipartFiles = [];
    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        multipartFiles.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        );
      }
    }

    FormData formData = FormData.fromMap({
      "type": 'SAVE',
      "note": voucher.note ?? "",
      "subTotal": voucher.subTotal,
      "tax": voucher.tax,
      "deliveryFee": voucher.deliveryFee,
      "remainingPaymentAmount": voucher.remainingPaymentAmount,
      "totalPaymentAmount": voucher.totalPaymentAmount,
      "total": voucher.total,
      "items": itemsJson,
      "payments": paymentsJson,
      if (multipartFiles.isNotEmpty) "files": multipartFiles,
    });

    final response = await _dio.post(url, data: formData);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      // Refresh the list automatically
      // state = const AsyncLoading();
      // state = AsyncData(await getVouchers());
      return {"success": true, "id": data["data"]["id"]};
    }

    throw Exception("Failed to create voucher");
  }
}

/// Provider
final voucherProvider =
    AsyncNotifierProvider<VoucherAsyncNotifier, List<VoucherDetailModel>>(
      VoucherAsyncNotifier.new,
    );
