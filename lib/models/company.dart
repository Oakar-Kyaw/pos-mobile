class Company {
  final int id;
  final String email;
  final String name;
  final String password;
  final String? photoUrl;
  final String? code;
  final String? address;
  final String? phone;

  Company({
    required this.id,
    required this.email,
    required this.name,
    this.password = "",
    this.photoUrl,
    this.code,
    this.address,
    this.phone,
  });

  /// 🔹 From JSON
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      code: json['code'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
    );
  }

  /// 🔹 To JSON (for create / update)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'code': code,
      'address': address,
      'phone': phone,
      'password': password,
    };
  }

  /// 🔹 CopyWith (very useful in state management)
  Company copyWith({
    int? id,
    String? email,
    String? name,
    String? photoUrl,
    String? code,
    String? address,
    String? phone,
  }) {
    return Company(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      code: code ?? this.code,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }
}
