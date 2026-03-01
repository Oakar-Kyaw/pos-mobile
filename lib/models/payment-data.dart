class PaymentData {
  final int id;
  final String? accountNumber;
  final String accountName;
  final String accountType;
  final double balance;

  const PaymentData({
    required this.id,
    this.accountNumber,
    required this.accountName,
    required this.accountType,
    required this.balance,
  });

  /// -------- FROM JSON --------
  factory PaymentData.fromJson(Map<String, dynamic> json) {
    // print("payemnt data ${json["balance"]}");
    return PaymentData(
      id: json['id'],
      accountNumber: json['accountNumber'],
      accountName: json['accountName'],
      accountType: json['accountType'],
      balance: double.parse(json["balance"].toString()),
    );
  }

  /// -------- TO JSON --------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    double? balance,
  }) {
    return PaymentData(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
      balance: balance ?? this.balance,
    );
  }
}
