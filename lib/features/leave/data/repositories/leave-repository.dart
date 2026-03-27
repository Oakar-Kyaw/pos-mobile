import 'package:pos/features/leave/data/datasources/leave-api.dart';
import 'package:pos/features/leave/data/models/create-leave.dart';
import 'package:pos/features/leave/data/models/leave-model.dart';

class LeaveRepository {
  final LeaveApi api;
  LeaveRepository(this.api);

  Future<bool> createLeave(CreateLeaveRequest request) async {
    final res = await this.api.createLeave(request);
    return res["success"] == true;
  }

  /// GET LIST
  Future<List<LeaveModel>> getLeaves({
    required int page,
    required int limit,
    int? filterUserId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final res = await api.getLeaves(
      page: page,
      limit: limit,
      filterUserId: filterUserId,
      startDate: startDate,
      endDate: endDate,
    );

    if (res["success"]) {
      return LeaveModel.listFromJson(res["data"]);
    }

    throw Exception("Failed to fetch leaves");
  }
}
