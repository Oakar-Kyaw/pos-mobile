import 'package:pos/features/account-upgrade/data/datasources/plan-api.dart';
import 'package:pos/features/account-upgrade/data/models/plan-model.dart';

class PlanRepository {
  final PlanApi api;

  PlanRepository(this.api);

  /// GET PLAN LIST
  Future<List<PlanModel>> getPlans() async {
    final res = await api.getPlans();

    if (res["success"]) {
      return PlanModel.listFromJson(res["data"]);
    }

    throw Exception("Failed to fetch plans");
  }
}
