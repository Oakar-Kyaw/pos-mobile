import 'package:pos/api/dio.dart';

class PlanApi {
  final DioService _dio;

  PlanApi(this._dio);

  /// GET PLAN LIST
  Future<Map<String, dynamic>> getPlans() async {
    final response = await _dio.get("v1/plans");

    return response.data;
  }
}
