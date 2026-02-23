class PaymentData {
  final int id;
  final String name;
  final String? accountNumber;
  final String accountName;
  final String accountType;

  const PaymentData({
    required this.id,
    required this.name,
    this.accountNumber,
    required this.accountName,
    required this.accountType,
  });

  /// -------- FROM JSON --------
  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      id: json['id'],
      name: json['name'],
      accountNumber: json['accountNumber'],
      accountName: json['accountName'],
      accountType: json['accountType'],
    );
  }

  /// -------- TO JSON --------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'accountType': accountType,
    };
  }

  /// -------- COPY WITH --------
  PaymentData copyWith({
    int? id,
    String? name,
    String? accountNumber,
    String? accountName,
    String? accountType,
  }) {
    return PaymentData(
      id: id ?? this.id,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
    );
  }
}
