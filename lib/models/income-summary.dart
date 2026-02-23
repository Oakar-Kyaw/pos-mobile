class IncomeSummary {
  final double monthlyIncome;
  final double yearlyIncome;

  IncomeSummary({required this.monthlyIncome, required this.yearlyIncome});

  // Convert from JSON
  factory IncomeSummary.fromJson(Map<String, dynamic> json) {
    return IncomeSummary(
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      yearlyIncome: (json['yearlyIncome'] as num).toDouble(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'monthlyIncome': monthlyIncome, 'yearlyIncome': yearlyIncome};
  }
}
