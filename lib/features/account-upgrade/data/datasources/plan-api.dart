import 'package:dio/dio.dart';
import 'package:pos/api/dio.dart';

class PlanApi {
  final DioService _dio;

  PlanApi(this._dio);

  /// GET PLAN LIST
  Future<Map<String, dynamic>> getPlans() async {
    final response = await _dio.get("v1/plans");

    return response.data;
  }

  /// UPGRADE PLAN LIST
  Future<Map<String, dynamic>> upgradePlans({required FormData json}) async {
    _dio.setContentType("multipart/form-data");
    final response = await _dio.post("v1/subscriptions", data: json);

    return response.data;
  }
}
