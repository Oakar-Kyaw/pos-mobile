import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/features/account-upgrade/data/datasources/plan-api.dart';
import 'package:pos/features/account-upgrade/data/repositories/plan-repository.dart';
import 'package:pos/features/account-upgrade/domain/entites/plan.dart';

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final dio = DioService();
  final api = PlanApi(dio);
  final repository = PlanRepository(api);
  return repository;
});

class PlanNotifier extends AsyncNotifier<List<Plan>> {
  @override
  Future<List<Plan>> build() async {
    return await fetchPlans();
  }

  /// GET LIST
  Future<List<Plan>> fetchPlans() async {
    final repo = ref.read(planRepositoryProvider);

    final result = await repo.getPlans();

    return result;
  }
}

final planProvider = AsyncNotifierProvider<PlanNotifier, List<Plan>>(
  PlanNotifier.new,
);
