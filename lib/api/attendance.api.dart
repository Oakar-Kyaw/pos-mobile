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
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    int? filterUserId,
  }) async {
    final url = "v1/attendances";

    // Build query map dynamically
    final Map<String, dynamic> query = {
      "page": page,
      "limit": limit,
      if (search != null && search.isNotEmpty) "search": search,
      if (date != null) "date": date.toIso8601String(),
      if (startDate != null) "startDate": startDate.toIso8601String(),
      if (endDate != null) "endDate": endDate.toIso8601String(),
      if (filterUserId != null) "filterUserId": filterUserId,
    };

    final response = await _dio.get(url, query: query);

    final data = response.data as Map<String, dynamic>;

    if (data["success"] == true) {
      final items = data["data"] as List;
      return Attendance.listFromJson(items);
    }

    throw Exception("Failed to fetch attendances");
  }

  /// -------- GET ALL ATTENDANCES AND GROUP BY STATUS --------
  Future<AttendanceGroupedByStatus> getMonthlyAttendanceGroupedByStatus({
    DateTime? date,
    int? filterUserId,
  }) async {
    final url = "v1/attendances/monthly/grouped";

    // Build query map dynamically
    final Map<String, dynamic> query = {
      if (date != null) "date": date.toIso8601String(),
      if (filterUserId != null) "filterUserId": filterUserId,
    };

    final response = await _dio.get(url, query: query);

    final data = response.data as Map<String, dynamic>;

    if (data["success"] == true) {
      return AttendanceGroupedByStatus.fromJson(data);
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

  /// -------- DELETE ATTENDANCE --------
  Future<bool> deleteAttendance(int id) async {
    final url = "v1/attendances/$id";

    final response = await _dio.delete(url);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      return true;
    }

    throw Exception(data["message"] ?? "Failed to delete attendance");
  }

  /// -------- GET ATTENDANCE BY ID --------
  Future<Attendance?> getAttendanceByUserIdAndDate({
    required DateTime date,
  }) async {
    final url = "v1/attendances/date/filter";

    final response = await _dio.get(
      url,
      query: {"date": date.toIso8601String()},
    );

    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      if (data["data"] != null) {
        // print("data is 🥹 $data");
        return Attendance.fromJson(Map<String, dynamic>.from(data["data"]));
      } else {
        // No attendance found for the date
        return null;
      }
    }

    throw Exception("Failed to fetch attendance");
  }

  /// -------- CREATE ATTENDANCE --------
  Future<Map<String, dynamic>> createAttendance({
    required DateTime date,
    String? overtimeType,
    String? overtimeMinutes,
    int? userId,
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
        if (userId != null) "userId": userId,
        "checkIn": checkIn,
        "checkOut": checkOut,
        "note": note,
        "workingMinutes": workingHours,
        'overtimeType': overtimeType,
        'overtimeMinutes': overtimeMinutes,
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
    print(" attendance api ${date.toIso8601String()}");
    final response = await _dio.post(
      url,
      data: {
        "date": date.toIso8601String(),
        "workingMinutes": workingHours,
        "lat": lat,
        "long": long,
      },
    );

    final data = response.data;
    if (data["success"] == true) {
      return {"success": true};
    }

    throw Exception("Failed to create attendance");
  }

  /// -------- CREATE Check out --------
  Future<Map<String, dynamic>> createCheckOut({
    required DateTime date,
    String? checkOut,
    String? workingHours,
  }) async {
    final url = "v1/attendances/user/check-out";
    //print(" attendance api ${date.toIso8601String()}");
    final response = await _dio.post(
      url,
      data: {"date": date.toIso8601String(), "workingMinutes": workingHours},
    );

    final data = response.data;
    //  print("data is $data");
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

final todayAttendanceProvider = FutureProvider.autoDispose<Attendance?>((
  ref,
) async {
  final notifier = ref.read(attendanceProvider.notifier);
  final date = DateTime.now();
  return await notifier.getAttendanceByUserIdAndDate(date: date);
});
