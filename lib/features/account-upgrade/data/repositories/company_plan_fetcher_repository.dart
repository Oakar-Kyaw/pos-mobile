import 'package:pos/features/account-upgrade/data/datasources/company_plan_fetcher_api.dart';
import 'package:pos/features/account-upgrade/data/models/company-plan-fetcher-model.dart';

class CompanyPlanFetcherRepository {
  final CompanyPlanFetcherApi api;

  CompanyPlanFetcherRepository(this.api);

  /// GET PLAN LIST
  Future<CompanyPlanFetcherModel> getPlans() async {
    final res = await api.get();

    if (res["success"]) {
      return CompanyPlanFetcherModel.fromJson(res["data"]);
    }

    throw Exception("Failed to fetch current company plans");
  }
}
