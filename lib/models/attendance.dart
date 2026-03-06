import 'package:pos/models/user.dart';

class Attendance {
  final int id;
  final int userId;
  final User? user;
  final int companyId;
  final int? branchId;

  final DateTime date;

  final String? checkIn;
  final String? checkOut;

  final double? workingHours;

  final String status;
  final String? note;

  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.userId,
    required this.companyId,
    this.branchId,
    this.user,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.workingHours,
    required this.status,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      userId: json['userId'],
      companyId: json['companyId'],
      branchId: json['branchId'],

      date: DateTime.parse(json['date']),

      checkIn: json['checkIn'],
      checkOut: json['checkOut'],
      user: User.fromJson(json["user"]),

      workingHours: json['workingHours'] != null
          ? double.tryParse(json['workingHours'].toString())
          : null,

      status: json['status'],
      note: json['note'],

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'companyId': companyId,
      'branchId': branchId,
      'date': date.toIso8601String(),
      'checkIn': checkIn,
      'checkOut': checkOut,
      'workingHours': workingHours,
      'status': status,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static List<Attendance> listFromJson(List<dynamic> list) {
    return list.map((e) => Attendance.fromJson(e)).toList();
  }
}
