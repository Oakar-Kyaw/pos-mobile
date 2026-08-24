import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/core/provider.dart';
import 'package:pos/models/company.dart';

class CompanyInfoAsyncNotifier extends AsyncNotifier<Company> {
  late DioService _dio;
  @override
  Future<Company> build() async {
    _dio = ref.watch(dioServiceProvider);
    return await getCompanyById();
  }

  Future<Company> getCompanyById() async {
    final url = "v1/companies";
    final response = await _dio.get(url);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final items = data["data"];
      Company company = Company.fromJson(Map<String, dynamic>.from(items));
      return company;
    }

    throw Exception("Failed to fetch currencies");
  }

  Future<Company> postCompany(Map<String, dynamic> json) async {
    final url = "v1/companies";
    final response = await _dio.post(url, data: json);
    final Map<String, dynamic> data = response.data;
    print("🤩 data is $data");
    if (data["success"] == true) {
      final items = data["data"];
      Company company = Company.fromJson(Map<String, dynamic>.from(items));
      return company;
    }

    throw Exception("Failed to post");
  }
}

final companyProvider = AsyncNotifierProvider(CompanyInfoAsyncNotifier.new);
