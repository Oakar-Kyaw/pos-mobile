import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/attendance.dart';

class AttendanceAsyncNotifier extends AsyncNotifier<List<Attendance>> {
  final DioService _dio = DioService();

  @override
  Future<List<Attendance>> build() async {
    return await getAttendances(page: 1, limit: 10);
  }

  /// -------- GET ALL ATTENDANCES --------
  Future<List<Attendance>> getAttendances({
    required int page,
    required int limit,
    String? search,
  }) async {
    final url = "v1/attendances";

    final response = await _dio.get(
      url,
      query: {"page": page, "limit": limit, "search": search},
    );

    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final items = data["data"] as List;

      List<Attendance> attendances = Attendance.listFromJson(items);

      return attendances;
    }

    throw Exception("Failed to fetch attendances");
  }

  /// -------- GET ATTENDANCE BY ID --------
  Future<Attendance> getAttendanceById(int id) async {
    final url = "v1/attendances/$id";

    final response = await _dio.get(url);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      return Attendance.fromJson(Map<String, dynamic>.from(data["data"]));
    }

    throw Exception("Failed to fetch attendance");
  }

  /// -------- CREATE ATTENDANCE --------
  Future<Map<String, dynamic>> createAttendance({
    required DateTime date,
    String? status,
    String? checkIn,
    String? checkOut,
    String? note,
    String? workingHours,
    String? lat,
    String? long,
  }) async {
    final url = "v1/attendances";
    print(" attendance api ${date.toIso8601String()}");
    final response = await _dio.post(
      url,
      data: {
        "date": date.toIso8601String(),
        "checkIn": checkIn,
        "checkOut": checkOut,
        "note": note,
        "workingHours": workingHours,
        "status": status,
        "lat": lat,
        "long": long,
      },
    );

    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      return {"success": true, "id": data["data"]["id"]};
    }

    throw Exception("Failed to create attendance");
  }

  /// -------- CREATE ATTENDANCE --------
  Future<Map<String, dynamic>> createCheckIn({
    required DateTime date,
    String? checkIn,
    String? workingHours,
    String? lat,
    String? long,
  }) async {
    final url = "v1/attendances/check-in";
    //print(" attendance api ${date.toIso8601String()}");
    final response = await _dio.post(
      url,
      data: {
        "date": date.toIso8601String(),
        "checkIn": checkIn,
        "workingHours": workingHours,
        "lat": lat,
        "long": long,
      },
    );

    final data = response.data;
    print("data is $data");
    if (data["success"] == true) {
      await this.refresh();
      return {"success": true};
    }

    throw Exception("Failed to create attendance");
  }

  /// -------- UPDATE ATTENDANCE --------
  Future<void> updateAttendance({
    required int id,
    String? checkIn,
    String? checkOut,
    String? note,
  }) async {
    final url = "v1/attendances/$id";

    final response = await _dio.patch(
      url,
      data: {"checkIn": checkIn, "checkOut": checkOut, "note": note},
    );

    final Map<String, dynamic> data = response.data;

    if (data["success"] != true) {
      throw Exception("Failed to update attendance");
    }
  }

  /// -------- DELETE ATTENDANCE --------
  Future<void> deleteAttendance(int id) async {
    final url = "v1/attendances/$id";

    final response = await _dio.delete(url);
    final Map<String, dynamic> data = response.data;

    if (data["success"] != true) {
      throw Exception("Failed to delete attendance");
    }
  }

  /// -------- SEARCH --------
  Future<void> searchAttendance(String search) async {
    state = const AsyncLoading();

    try {
      final result = await getAttendances(page: 1, limit: 20, search: search);

      state = AsyncData(result);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  /// -------- REFRESH --------
  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final result = await getAttendances(page: 1, limit: 31);

      state = AsyncData(result);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

/// Provider
final attendanceProvider =
    AsyncNotifierProvider<AttendanceAsyncNotifier, List<Attendance>>(
      AttendanceAsyncNotifier.new,
    );
