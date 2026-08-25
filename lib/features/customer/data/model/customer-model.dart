class Customer {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final bool isDeleted;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    required this.isDeleted,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  static List<Customer> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Customer.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'isDeleted': isDeleted,
    };
  }
}
