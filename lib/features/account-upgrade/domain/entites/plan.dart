class Plan {
  final int id;
  final String name;
  final String title;
  final int durationDays;
  final int month;
  final String priceMMK;
  final String priceUSD;
  final int discountPercent;
  final bool isPopular;
  final bool isActive;
  final bool existBranch;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final List<PlanFeature> planFeatures;

  Plan({
    required this.id,
    required this.name,
    required this.title,
    required this.month,
    required this.durationDays,
    required this.priceMMK,
    required this.priceUSD,
    required this.discountPercent,
    required this.isPopular,
    required this.isActive,
    required this.existBranch,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.planFeatures,
  });
}

class PlanFeature {
  final int id;
  final int planId;
  final String icon;
  final String key;
  final String value;
  final DateTime createdAt;

  PlanFeature({
    required this.id,
    required this.planId,
    required this.icon,
    required this.key,
    required this.value,
    required this.createdAt,
  });
}
