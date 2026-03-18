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

  final double? workingMinutes;

  final String status;
  final bool isLate;
  final bool isEarlyLeave;
  final String? note;
  final String overtimeType;
  final int overtimeMinutes;

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
    this.workingMinutes,
    required this.status,
    required this.isLate,
    required this.isEarlyLeave,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.overtimeType,
    required this.overtimeMinutes,
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

      workingMinutes: json['workingMinutes'] != null
          ? double.tryParse(json['workingHours'].toString())
          : null,

      status: json['status'],
      isLate: json['isLate'],
      isEarlyLeave: json['isEarlyLeave'],
      note: json['note'],
      overtimeType: json['overtimeType'],
      overtimeMinutes: json['overtimeMinutes'],

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
      'workingMinutes': workingMinutes,
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

class AttendanceGroupedByStatus {
  final List<Attendance> attendanceByAbsent;
  final List<Attendance> attendanceByPresent;
  final List<Attendance> attendanceByLate;
  final List<Attendance> attendanceByHalfDay;
  final List<Attendance> attendanceByHoliday;
  final List<Attendance> attendanceByLeave;
  final List<Attendance> attendanceByEarlyLeave; // new
  final List<Attendance> attendanceByBoth; // new

  // Summary counts
  final int totalDays;
  final int totalPresent;
  final int totalAbsent;
  final int totalHalfDay;
  final int totalLeave;
  final int totalHoliday;
  final int totalLate;
  final int totalEarlyLeave;
  final int totalBoth;

  AttendanceGroupedByStatus({
    required this.attendanceByAbsent,
    required this.attendanceByPresent,
    required this.attendanceByLate,
    required this.attendanceByHalfDay,
    required this.attendanceByHoliday,
    required this.attendanceByLeave,
    required this.attendanceByEarlyLeave,
    required this.attendanceByBoth,
    required this.totalDays,
    required this.totalPresent,
    required this.totalAbsent,
    required this.totalHalfDay,
    required this.totalLeave,
    required this.totalHoliday,
    required this.totalLate,
    required this.totalEarlyLeave,
    required this.totalBoth,
  });

  factory AttendanceGroupedByStatus.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? {};

    return AttendanceGroupedByStatus(
      attendanceByAbsent: Attendance.listFromJson(
        json['attendanceByAbsent'] ?? [],
      ),
      attendanceByPresent: Attendance.listFromJson(
        json['attendanceByPresent'] ?? [],
      ),
      attendanceByLate: Attendance.listFromJson(json['attendanceByLate'] ?? []),
      attendanceByHalfDay: Attendance.listFromJson(
        json['attendanceByHalfDay'] ?? [],
      ),
      attendanceByHoliday: Attendance.listFromJson(
        json['attendanceByHoliday'] ?? [],
      ),
      attendanceByLeave: Attendance.listFromJson(
        json['attendanceByLeave'] ?? [],
      ),
      attendanceByEarlyLeave: Attendance.listFromJson(
        json['attendanceByEarlyLeave'] ?? [],
      ),
      attendanceByBoth: Attendance.listFromJson(json['attendanceByBoth'] ?? []),

      // Summary counts
      totalDays: summary['totalDays'] ?? 0,
      totalPresent: summary['totalPresent'] ?? 0,
      totalAbsent: summary['totalAbsent'] ?? 0,
      totalHalfDay: summary['totalHalfDay'] ?? 0,
      totalLeave: summary['totalLeave'] ?? 0,
      totalHoliday: summary['totalHoliday'] ?? 0,
      totalLate: summary['totalLate'] ?? 0,
      totalEarlyLeave: summary['totalEarlyLeave'] ?? 0,
      totalBoth: summary['totalBoth'] ?? 0,
    );
  }
}
