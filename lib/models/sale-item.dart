class SaleItem {
  final String name;
  final int quantity;
  final double totalAmount;

  SaleItem({
    required this.name,
    required this.quantity,
    required this.totalAmount,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      name: json['name'],
      quantity: json['quantity'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'totalAmount': totalAmount};
  }
}
