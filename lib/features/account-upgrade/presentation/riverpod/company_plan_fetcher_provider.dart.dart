import 'package:pos/core/provider.dart';
import 'package:pos/features/account-upgrade/data/datasources/company_plan_fetcher_api.dart';
import 'package:pos/features/account-upgrade/data/repositories/company_plan_fetcher_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
CompanyPlanFetcherRepository companyPlanFetcher(Ref ref) {
  final _dio = ref.watch(dioServiceProvider);
  final api = CompanyPlanFetcherApi(_dio);
  return CompanyPlanFetcherRepository(api);
}
