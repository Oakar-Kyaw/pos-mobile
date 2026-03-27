import 'package:pos/features/account-upgrade/domain/entites/plan.dart';

class PlanFeatureModel extends PlanFeature {
  PlanFeatureModel({
    required super.id,
    required super.planId,
    required super.icon,
    required super.key,
    required super.value,
    required super.createdAt,
  });

  // FROM JSON
  factory PlanFeatureModel.fromJson(Map<String, dynamic> json) {
    return PlanFeatureModel(
      id: json['id'],
      planId: json['planId'],
      icon: json['icon'],
      key: json['key'],
      value: json['value'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "planId": planId,
      "icon": icon,
      "key": key,
      "value": value,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  // 🔄 LIST
  static List<PlanFeatureModel> listFromJson(List<dynamic> list) {
    return list.map((e) => PlanFeatureModel.fromJson(e)).toList();
  }
}
