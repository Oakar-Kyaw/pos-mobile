import 'package:pos/api/dio.dart';

class CompanyPlanFetcherApi {
  final DioService _dio;

  CompanyPlanFetcherApi(this._dio);

  /// GET COMPANY'S CURRENT PLAN
  Future<Map<String, dynamic>> get() async {
    final response = await _dio.get(
      "v1/subscriptions/company/current-subscription",
    );

    return response.data;
  }
}
