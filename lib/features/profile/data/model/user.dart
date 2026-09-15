import 'package:pos/features/company/data/model/company.dart';

class User {
  final int id;
  final int companyId;
  final String email;
  final String role;
  final String employeeType;

  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? photoUrl;
  final String? address;

  final String gender;

  final double? monthlySalary;
  final double? hourlySalary;
  final bool locationRestrict;
  final List<String> holidays;
  final String? startTime;
  final String? endTime;

  final int? branchId;

  final DateTime createdAt;
  final DateTime? dateOfBirth;

  final Company? company;

  User({
    required this.id,
    required this.companyId,
    required this.email,
    required this.role,
    required this.employeeType,
    this.firstName,
    this.lastName,
    this.phone,
    this.photoUrl,
    this.address,
    required this.gender,
    this.monthlySalary,
    this.hourlySalary,
    this.locationRestrict = false,
    required this.holidays,
    this.startTime,
    this.endTime,
    this.branchId,
    required this.createdAt,
    this.dateOfBirth,
    this.company,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    companyId: json['companyId'],
    email: json['email'],
    role: json['role'],
    employeeType: json['employeeType'] ?? '',
    firstName: json['firstName'],
    lastName: json['lastName'],
    phone: json['phone'],
    photoUrl: json['photoUrl'],
    address: json['address'],
    gender: json['gender'] ?? '',
    hourlySalary: json['hourlySalary'] != null
        ? double.tryParse(json['hourlySalary'].toString())
        : null,
    monthlySalary: json['monthlySalary'] != null
        ? double.tryParse(json['monthlySalary'].toString())
        : null,
    locationRestrict: json['locationRestrict'] ?? false,
    holidays:
        (json['holidays'] as List?)?.map((e) => e.toString()).toList() ?? [],
    startTime: json['startTime'],
    endTime: json['endTime'],
    branchId: json['branchId'],
    createdAt: DateTime.parse(json['createdAt']),
    dateOfBirth: json['dateOfBirth'] != null
        ? DateTime.parse(json['dateOfBirth'])
        : null,
    company: json['company'] != null ? Company.fromJson(json['company']) : null,
  );

  static List<User> listFromJson(List<dynamic> json) =>
      json.map((e) => User.fromJson(e)).toList();
}
