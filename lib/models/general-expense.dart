class GeneralExpense {
  final int id;
  final String title;
  final String? reason;
  final double amount;
  final DateTime date;

  GeneralExpense({
    required this.id,
    required this.title,
    this.reason,
    required this.amount,
    required this.date,
  });

  // 🔄 From JSON
  factory GeneralExpense.fromJson(Map<String, dynamic> json) {
    return GeneralExpense(
      id: json['id'],
      title: json['title'],
      reason: json['reason'],
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['date']),
    );
  }

  // 🔄 To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'reason': reason,
      'amount': amount.toString(),
      'date': date.toIso8601String(),
    };
  }
}
