import 'package:pos/models/user.dart';

class SalaryDeductionItem {
  final DateTime? date;
  final int? lateMinutes;
  final int? earlyLeaveMinutes;
  final int? ruleId;
  final int? threshold;
  final double deduction;

  SalaryDeductionItem({
    this.date,
    this.lateMinutes,
    this.earlyLeaveMinutes,
    this.ruleId,
    this.threshold,
    required this.deduction,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  factory SalaryDeductionItem.fromJson(Map<String, dynamic> json) {
    return SalaryDeductionItem(
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      lateMinutes: _toIntOrNull(json['lateMinutes']),
      earlyLeaveMinutes: _toIntOrNull(json['earlyLeaveMinutes']),
      ruleId: _toIntOrNull(json['ruleId']),
      threshold: _toIntOrNull(json['threshold']),
      deduction: _toDouble(json['deduction']),
    );
  }
}

class CalculateSalaryData {
  final double totalSalary;
  final double salaryByDay;
  final double attendanceSalary;
  final double overtime;
  final int workedDays;
  final double lateDeduction;
  final double earlyLeaveDeduction;
  final double absentDeduction;
  final double leaveDeduction;
  final double totalDeductions;
  final double netSalary;
  final List<SalaryDeductionItem> lateDeductionItems;
  final List<SalaryDeductionItem> earlyLeaveDeductionItems;

  CalculateSalaryData({
    required this.totalSalary,
    required this.salaryByDay,
    required this.attendanceSalary,
    required this.workedDays,
    required this.overtime,
    required this.lateDeduction,
    required this.earlyLeaveDeduction,
    required this.absentDeduction,
    required this.leaveDeduction,
    required this.totalDeductions,
    required this.netSalary,
    required this.lateDeductionItems,
    required this.earlyLeaveDeductionItems,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static List<SalaryDeductionItem> _items(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (e) => SalaryDeductionItem.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }
    return [];
  }

  factory CalculateSalaryData.fromJson(Map<String, dynamic> json) {
    // print("jsonn is ${json}");
    return CalculateSalaryData(
      totalSalary: _toDouble(json['totalSalary']),
      salaryByDay: _toDouble(json['salaryByDay']),
      overtime: _toDouble(json["overtime"]),
      attendanceSalary: _toDouble(json['attendanceSalary']),
      workedDays: _toInt(json['workedDays']),
      lateDeduction: _toDouble(json['lateDeduction']),
      earlyLeaveDeduction: _toDouble(json['earlyLeaveDeduction']),
      absentDeduction: _toDouble(json['absentDeduction']),
      leaveDeduction: _toDouble(json['leaveDeduction']),
      totalDeductions: _toDouble(json['totalDeductions']),
      netSalary: _toDouble(json['netSalary']),
      lateDeductionItems: _items(json['lateDeductionItems']),
      earlyLeaveDeductionItems: _items(json['earlyLeaveDeductionItems']),
    );
  }

  static List<CalculateSalaryData> listFromJson(List<dynamic> list) {
    return list.map((e) => CalculateSalaryData.fromJson(e)).toList();
  }
}

class CalculateSalaryResponse {
  final bool success;
  final String message;
  final CalculateSalaryData data;

  CalculateSalaryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CalculateSalaryResponse.fromJson(Map<String, dynamic> json) {
    return CalculateSalaryResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: CalculateSalaryData.fromJson(
        Map<String, dynamic>.from(json['data'] ?? {}),
      ),
    );
  }
}

class PayrollRecord {
  final int id;
  final int userId;
  final int approveUserId;
  final int companyId;
  final int? branchId;
  final int month;
  final int year;
  final double baseSalary;
  final double lateDeduction;
  final double earlyLeaveDeduction;
  final double overtime;
  final double bonus;
  final double deduction;
  final double leaveDeduction;
  final double netSalary;
  final double totalDeductions;
  final int totalWorkingDays;
  final int presentDays;
  final int absentDays;
  final int halfDays;
  final double leaveDays;
  final int lateTotalMinutes;
  final int earlyLeaveTotalMinutes;
  final int overtimeTotalMinutes;
  final int overtimeDays;
  final String status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;

  PayrollRecord({
    required this.id,
    required this.userId,
    required this.approveUserId,
    required this.companyId,
    this.branchId,
    required this.month,
    required this.year,
    required this.baseSalary,
    required this.lateDeduction,
    required this.earlyLeaveDeduction,
    required this.overtime,
    required this.bonus,
    required this.deduction,
    required this.leaveDeduction,
    required this.netSalary,
    required this.totalDeductions,
    required this.totalWorkingDays,
    required this.presentDays,
    required this.absentDays,
    required this.halfDays,
    required this.leaveDays,
    required this.lateTotalMinutes,
    required this.earlyLeaveTotalMinutes,
    required this.overtimeTotalMinutes,
    required this.overtimeDays,
    required this.status,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime _toDate(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory PayrollRecord.fromJson(Map<String, dynamic> json) {
    return PayrollRecord(
      id: _toInt(json['id']),
      userId: _toInt(json['userId']),
      approveUserId: _toInt(json['approveUserId']),
      companyId: _toInt(json['companyId']),
      branchId: json['branchId'] != null ? _toInt(json['branchId']) : null,
      month: _toInt(json['month']),
      year: _toInt(json['year']),
      baseSalary: _toDouble(json['baseSalary']),
      lateDeduction: _toDouble(json['lateDeduction']),
      earlyLeaveDeduction: _toDouble(json['earlyLeaveDeduction']),
      overtime: _toDouble(json['overtime']),
      bonus: _toDouble(json['bonus']),
      deduction: _toDouble(json['deduction']),
      leaveDeduction: _toDouble(json['leaveDeduction']),
      netSalary: _toDouble(json['netSalary']),
      totalDeductions: _toDouble(json['totalDeductions']),
      totalWorkingDays: _toInt(json['totalWorkingDays']),
      presentDays: _toInt(json['presentDays']),
      absentDays: _toInt(json['absentDays']),
      halfDays: _toInt(json['halfDays']),
      leaveDays: _toDouble(json['leaveDays']),
      lateTotalMinutes: _toInt(json['lateTotalMinutes']),
      earlyLeaveTotalMinutes: _toInt(json['earlyLeaveTotalMinutes']),
      overtimeTotalMinutes: _toInt(json['overtimeTotalMinutes']),
      overtimeDays: _toInt(json['overtimeDays']),
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      createdAt: _toDate(json['createdAt']),
      updatedAt: _toDate(json['updatedAt']),
      user: User.fromJson(Map<String, dynamic>.from(json['user'] ?? {})),
    );
  }

  static List<PayrollRecord> listFromJson(List<dynamic> list) {
    return list
        .map((e) => PayrollRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

