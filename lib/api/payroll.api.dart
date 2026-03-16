import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/payroll.dart';

class PayrollAsyncNotifier extends AsyncNotifier<List<PayrollRecord>> {
  final DioService _dio = DioService();

  @override
  Future<List<PayrollRecord>> build() async {
    return await getAllPayroll(page: 1, limit: 10);
  }

  /// -------- GET ALL PAYROLLS --------
  Future<List<PayrollRecord>> getAllPayroll({
    required int page,
    required int limit,
    int? userId,
    int? month,
    int? year,
    int? branchId,
  }) async {
    final url = 'v1/payrolls';

    final Map<String, dynamic> query = {
      'page': page,
      'limit': limit,
      if (userId != null) 'filterUserId': userId,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (branchId != null) 'branchId': branchId,
    };

    final response = await _dio.get(url, query: query);
    final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);

    if (data['success'] == true) {
      final items = List<Map<String, dynamic>>.from(data['data'] ?? []);
      return PayrollRecord.listFromJson(items);
    }

    throw Exception(data['message'] ?? 'Failed to fetch payrolls');
  }

  /// -------- CALCULATE PAYROLL --------
  Future<CalculateSalaryData> calculatePayroll({
    required String date,
    required int userId,
  }) async {
    final url = 'v1/payrolls/calculate';

    final response = await _dio.post(
      url,
      data: {"date": date, "userId": userId},
    );

    final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);

    if (data['success'] == true) {
      return CalculateSalaryData.fromJson(data["data"]);
    }

    throw Exception(data['message'] ?? 'Failed to calculate payroll');
  }

  /// -------- CREATE PAYROLL --------
  Future<Map<String, dynamic>> createPayroll(Map<String, dynamic> json) async {
    final url = 'v1/payrolls';

    final response = await _dio.post(url, data: json);

    final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);

    if (data['success'] == true) {
      return {"success": true, "payrollId": data["data"]["id"]};
    }

    throw Exception(data['message'] ?? 'Failed to calculate payroll');
  }

  /// -------- GET PAYROLL BY ID --------
  Future<PayrollRecord> getPayrollById(int id) async {
    final url = 'v1/payrolls/$id';

    final response = await _dio.get(url);

    final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);

    if (data['success'] == true) {
      return PayrollRecord.fromJson(Map<String, dynamic>.from(data['data']));
    }

    throw Exception(data['message'] ?? 'Failed to fetch payroll');
  }

  /// -------- DELETE PAYROLL --------
  Future<bool> deletePayroll(int id) async {
    final url = 'v1/payrolls/$id';

    final response = await _dio.delete(url);
    final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);

    if (data['success'] == true) {
      return true;
    }

    throw Exception(data['message'] ?? 'Failed to delete payroll');
  }
}

final payrollProvider =
    AsyncNotifierProvider<PayrollAsyncNotifier, List<PayrollRecord>>(
      PayrollAsyncNotifier.new,
    );
