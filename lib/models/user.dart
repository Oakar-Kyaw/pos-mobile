class User {
  final int id;
  final String email;
  final String role;
  final String employeeType;

  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? photoUrl;

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

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.employeeType,
    this.firstName,
    this.lastName,
    this.phone,
    this.photoUrl,
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
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    role: json['role'],
    employeeType: json['employeeType'] ?? null,
    firstName: json['firstName'],
    lastName: json['lastName'],
    phone: json['phone'],
    photoUrl: json['photoUrl'],
    gender: json['gender'] ?? null,
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
    branchId: json['branchId'] ?? null,
    createdAt: DateTime.parse(json['createdAt']),
    dateOfBirth: json['dateOfBirth'] != null
        ? DateTime.parse(json['dateOfBirth'])
        : null,
  );

  static List<User> listFromJson(List<dynamic> json) =>
      json.map((e) => User.fromJson(e)).toList();
}
