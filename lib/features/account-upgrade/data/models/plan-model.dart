import 'package:pos/features/account-upgrade/data/models/plan-feature-model.dart';
import 'package:pos/features/account-upgrade/domain/entites/plan.dart';

class PlanModel extends Plan {
  PlanModel({
    required super.id,
    required super.name,
    required super.title,
    required super.durationDays,
    required super.priceMMK,
    required super.priceUSD,
    required super.discountPercent,
    required super.isPopular,
    required super.isActive,
    required super.existBranch,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
    required super.planFeatures,
  });

  // FROM JSON
  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      durationDays: json['durationDays'],
      priceMMK: json['priceMMK'].toString(),
      priceUSD: json['priceUSD'].toString(),
      discountPercent: json['discountPercent'] ?? 0,
      isPopular: json['isPopular'] ?? false,
      isActive: json['isActive'] ?? false,
      existBranch: json['existBranch'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isDeleted: json['isDeleted'] ?? false,
      planFeatures: json['planFeatures'] != null
          ? (json['planFeatures'] as List)
                .map((e) => PlanFeatureModel.fromJson(e))
                .toList()
          : [],
    );
  }

  // 🔄 LIST
  static List<PlanModel> listFromJson(List<dynamic> list) {
    return list.map((e) => PlanModel.fromJson(e)).toList();
  }
}
