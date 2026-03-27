import 'package:pos/api/dio.dart';
import 'package:pos/features/leave/data/models/create-leave.dart';

class LeaveApi {
  final DioService _dio;

  LeaveApi(this._dio);

  /// CREATE LEAVE
  Future<Map<String, dynamic>> createLeave(CreateLeaveRequest request) async {
    final response = await _dio.post(
      "v1/leave", // adjust if your endpoint is different
      data: request.toJson(),
    );

    return response.data;
  }

  /// GET LEAVE LIST
  Future<Map<String, dynamic>> getLeaves({
    int page = 1,
    int limit = 10,
    int? filterUserId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _dio.get(
      "v1/leaves",
      query: {
        "page": page,
        "limit": limit,
        "filterUserId": filterUserId,
        "startDate": startDate,
        "endDate": endDate,
      },
    );

    return response.data;
  }

  ///  GET SINGLE LEAVE
  Future<Map<String, dynamic>> getLeave(int id) async {
    final response = await _dio.get("v1/leaves/$id");
    return response.data;
  }

  /// UPDATE LEAVE
  Future<Map<String, dynamic>> updateLeave(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch("v1/leaves/$id", data: data);

    return response.data;
  }

  /// DELETE LEAVE
  Future<Map<String, dynamic>> deleteLeave(int id) async {
    final response = await _dio.delete("v1/leaves/$id");
    return response.data;
  }
}
