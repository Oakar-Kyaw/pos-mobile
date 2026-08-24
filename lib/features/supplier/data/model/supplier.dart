class Supplier {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;

  Supplier({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  static List<Supplier> listFromJson(List<dynamic> json) {
    return json
        .map((item) => Supplier.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
