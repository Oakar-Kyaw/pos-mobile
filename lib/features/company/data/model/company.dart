import 'package:flutter/rendering.dart';

class Company {
  final int id;
  final String country;
  final String? code;
  final String email;
  final String name;
  final String password;
  final String? phone;
  final String? address;
  final String? photoUrl;
  final String? lat;
  final String? long;
  final String type;
  final bool isTrial;
  final DateTime? subscriptionEndDate;

  Company({
    required this.id,
    this.country = "MM",
    this.code,
    required this.email,
    required this.name,
    this.password = "",
    this.phone,
    this.address,
    this.photoUrl,
    this.lat,
    this.long,
    this.type = "SHOP",
    this.isTrial = true,
    this.subscriptionEndDate,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    debugPrint("company data is 🥶 $json");

    return Company(
      id: json['id'] as int,
      country: json['country'] as String? ?? "MM",
      code: json['code'] as String?,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      photoUrl: json['photoUrl'] as String?,
      lat: json['lat'] as String?,
      long: json['long'] as String?,
      type: json['type'] as String? ?? "SHOP",
      isTrial: json['isTrial'] as bool? ?? true,
      subscriptionEndDate: json['subscriptionEndDate'] != null
          ? DateTime.tryParse(json['subscriptionEndDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'photoUrl': photoUrl,
      'code': code,
      'address': address,
      'phone': phone,
      'country': country,
      'lat': lat,
      'long': long,
      'type': type,
    };
  }

  Company copyWith({
    int? id,
    String? country,
    String? code,
    String? email,
    String? name,
    String? password,
    String? phone,
    String? address,
    String? photoUrl,
    String? lat,
    String? long,
    String? type,
    bool? isTrial,
    DateTime? subscriptionEndDate,
  }) {
    return Company(
      id: id ?? this.id,
      country: country ?? this.country,
      code: code ?? this.code,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      type: type ?? this.type,
      isTrial: isTrial ?? this.isTrial,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
    );
  }
}
