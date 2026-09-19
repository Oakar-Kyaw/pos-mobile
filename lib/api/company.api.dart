import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/core/provider.dart';
import 'package:pos/features/company/data/model/company.dart';

class CompanyInfoAsyncNotifier extends AsyncNotifier<Company> {
  late DioService _dio;
  @override
  Future<Company> build() async {
    _dio = ref.watch(dioServiceProvider);
    throw UnimplementedError('Use getCompanys explicitly or split providers');
  }

  Future<Company> getCompanys() async {
    final url = "v1/companies";
    final response = await _dio.get(url);
    final Map<String, dynamic> data = response.data;
    if (data["success"] == true) {
      final items = data["data"];
      return Company.fromJson(Map<String, dynamic>.from(items));
    }
    throw Exception("Failed to fetch company");
  }

  Future<Company> postCompany(Map<String, dynamic> json) async {
    final url = "v1/companies";
    final response = await _dio.post(url, data: json);
    final Map<String, dynamic> data = response.data;
    if (data["success"] == true) {
      final items = data["data"];
      return Company.fromJson(Map<String, dynamic>.from(items));
    }
    throw Exception("Failed to post");
  }

  Future<bool> updateCompany(int companyId, FormData formData) async {
    final url = "v1/companies/$companyId";
    _dio.setContentType(
      "multipart/form-data",
    ); // ProductAsyncNotifier, postProduct pattern
    final response = await _dio.patch(url, data: formData);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final items = data["data"];
      final updated = Company.fromJson(Map<String, dynamic>.from(items));
      state = AsyncData(updated);
      return true;
    }
    throw Exception("Failed to update company");
  }
}

final companyProvider =
    AsyncNotifierProvider<CompanyInfoAsyncNotifier, Company>(
      CompanyInfoAsyncNotifier.new,
    );

final companyByIdProvider = FutureProvider.family<Company, int>((
  ref,
  companyId,
) async {
  final dio = ref.watch(dioServiceProvider);
  final url = "v1/companies/$companyId";

  final response = await dio.get(url);
  final Map<String, dynamic> data = response.data;

  if (data["success"] == true) {
    final items = data["data"];
    return Company.fromJson(Map<String, dynamic>.from(items));
  }

  throw Exception("Failed to fetch company");
});
