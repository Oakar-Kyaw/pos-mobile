import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/features/leave/data/datasources/leave-api.dart';
import 'package:pos/features/leave/data/models/create-leave.dart';
import 'package:pos/features/leave/data/repositories/leave-repository.dart';
import 'package:pos/features/leave/domain/entites/leave.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  final dio = DioService();
  final api = LeaveApi(dio);
  final repository = LeaveRepository(api);
  return repository;
});

class LeaveNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// GET LIST
  Future<List<Leave>> fetchLeaves({
    required int page,
    required int limit,
    int? filterUserId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final repo = ref.read(leaveRepositoryProvider);
    final result = await repo.getLeaves(
      page: page,
      limit: limit,
      filterUserId: filterUserId,
      startDate: startDate,
      endDate: endDate,
    );
    return result;
  }

  /// CREATE
  Future<bool> createLeave(CreateLeaveRequest request) async {
    final repo = ref.read(leaveRepositoryProvider);
    return repo.createLeave(request);
  }
  // Future<bool> createLeave(CreateLeaveRequest request) async {
  //   final repo = ref.read(leaveRepositoryProvider);

  //   final success = await repo.createLeave(request);

  //   if (success) {
  //     // 🔥 IMPORTANT: refresh list after create
  //     state = const AsyncLoading();
  //     state = AsyncData(await fetchLeaves());
  //   }

  //   return success;
  // }
}

final leaveProvider = AsyncNotifierProvider<LeaveNotifier, void>(
  LeaveNotifier.new,
);
