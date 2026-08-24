import 'package:pos/features/account-upgrade/domain/entites/company-plan-fetcher.dart';

class CompanyPlanFetcherModel extends CompanyPlanFetcher {
  CompanyPlanFetcherModel({
    required super.planName,
    required super.usdAmount,
    required super.mmkAmount,
  });

  // FROM JSON
  factory CompanyPlanFetcherModel.fromJson(Map<String, dynamic> json) {
    return CompanyPlanFetcherModel(
      planName: json['planName'],
      usdAmount: json['usdAmount'],
      mmkAmount: json['mmkAmount'],
    );
  }
}
