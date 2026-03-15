class HrRule {
  final int id;
  final int companyId;
  final int? branchId;

  final String type;

  final int? thresholdMinute;
  final int? thresholdAmount;
  final int? thresholdAmountPercent;

  final int? thresholdDays;

  final DateTime createdAt;
  final DateTime updatedAt;

  HrRule({
    required this.id,
    required this.companyId,
    this.branchId,
    required this.type,
    this.thresholdMinute,
    this.thresholdAmount,
    this.thresholdAmountPercent,
    this.thresholdDays,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HrRule.fromJson(Map<String, dynamic> json) {
    return HrRule(
      id: json['id'],
      companyId: json['companyId'],
      branchId: json['branchId'],
      type: json['type'],
      thresholdMinute: json['thresholdMinute'] ?? 0,
      thresholdAmount: json['thresholdAmount'] ?? 0,
      thresholdAmountPercent: json['thresholdAmountPercent'] ?? 0,
      thresholdDays: json['thresholdDays'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "thresholdMinute": thresholdMinute,
      "thresholdAmount": thresholdAmount,
      "thresholdAmountPercent": thresholdAmountPercent,
      "thresholdDays": thresholdDays,
    };
  }

  static List<HrRule> listFromJson(List<dynamic> list) {
    return list.map((e) => HrRule.fromJson(e)).toList();
  }

  // HrCardType toHrCardType() {
  //   switch (type) {
  //     case 'DEDUCT':
  //       return HrCardType(
  //         title: type,
  //         minutes: thresholdMinute,
  //         amount: thresholdAmount,
  //         percent: thresholdAmountPercent,
  //       );

  //     case 'EARLY_LEAVE':
  //       return HrCardType(
  //         title: type,
  //         minutes: earlyLeaveMinute,
  //         amount: earlyLeaveAmount,
  //         percent: earlyLeavePercent,
  //       );

  //     case 'OVERTIME':
  //       return HrCardType(
  //         title: type,
  //         minutes: overtimeMinute,
  //         day: overtimeDay,
  //         amount: overtimeAmount,
  //         percent: overtimeAmountPercent,
  //       );

  //     case 'LEAVE_ALLOW':
  //       return HrCardType(title: type, day: leaveAllowDay);

  //     default:
  //       return HrCardType(title: type);
  //   }
  // }
}

// class HrCardType {
//   final String title;
//   final int? day;
//   final int? minutes;
//   final int? percent;
//   final int? amount;
//   HrCardType({
//     required this.title,
//     this.day,
//     this.minutes,
//     this.amount,
//     this.percent,
//   });
// }

// class DeductRule {
//   final String type;
//   final int thresholdMinute;
//   final int? thresholdAmount;
//   final int? thresholdAmountPercent;

//   DeductRule({
//     required this.type,
//     required this.thresholdMinute,
//     this.thresholdAmount,
//     this.thresholdAmountPercent,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'type': type,
//       'thresholdMinute': thresholdMinute,
//       'thresholdAmount': thresholdAmount,
//       'thresholdAmountPercent': thresholdAmountPercent,
//     };
//   }

//   HrCardType toHrCardType() {
//     return HrCardType(
//       title: type,
//       minutes: thresholdMinute,
//       amount: thresholdAmount,
//       percent: thresholdAmountPercent,
//     );
//   }
// }

// class EarlyLeaveRule {
//   final String type;
//   final int earlyLeaveMinute;
//   final int? earlyLeaveAmount;
//   final int? earlyLeavePercent;

//   EarlyLeaveRule({
//     required this.type,
//     required this.earlyLeaveMinute,
//     this.earlyLeaveAmount,
//     this.earlyLeavePercent,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'type': type,
//       'earlyLeaveMinute': earlyLeaveMinute,
//       'earlyLeaveAmount': earlyLeaveAmount,
//       'earlyLeavePercent': earlyLeavePercent,
//     };
//   }

//   HrCardType toHrCardType() {
//     return HrCardType(
//       title: type,
//       minutes: earlyLeaveMinute,
//       amount: earlyLeaveAmount,
//       percent: earlyLeavePercent,
//     );
//   }
// }

// class OvertimeRule {
//   final String type;
//   final int? overtimeMinute;
//   final int? overtimeAmount;
//   final int? overtimeAmountPercent;
//   final int? overtimeDay;

//   OvertimeRule({
//     required this.type,
//     this.overtimeMinute,
//     this.overtimeAmount,
//     this.overtimeAmountPercent,
//     this.overtimeDay,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'type': type,
//       'overtimeMinute': overtimeMinute,
//       'overtimeAmount': overtimeAmount,
//       'overtimeAmountPercent': overtimeAmountPercent,
//       'overtimeDay': overtimeDay,
//     };
//   }

//   HrCardType toHrCardType() {
//     return HrCardType(
//       title: type,
//       amount: overtimeAmount,
//       percent: overtimeAmountPercent,
//       day: overtimeDay,
//       minutes: overtimeMinute,
//     );
//   }
// }

// class LeaveRule {
//   final String type;
//   final int leaveAllowDay;

//   LeaveRule({required this.type, required this.leaveAllowDay});

//   Map<String, dynamic> toJson() {
//     return {'type': type, 'leaveAllowDay': leaveAllowDay};
//   }

//   HrCardType toHrCardType() {
//     return HrCardType(title: type, day: leaveAllowDay);
//   }
// }

// class HRRuleFactory {
//   static dynamic buildHrRule({
//     required String ruleType,
//     String? thresholdMinute,
//     String? thresholdDay,
//     String? amount,
//     String? percent,
//   }) {
//     switch (ruleType) {
//       case 'DEDUCT':
//         return DeductRule(
//           type: ruleType,
//           thresholdMinute: int.tryParse(thresholdMinute ?? '') ?? 0,
//           thresholdAmount: amount?.isNotEmpty == true
//               ? int.tryParse(amount!)
//               : null,
//           thresholdAmountPercent: percent?.isNotEmpty == true
//               ? int.tryParse(percent!)
//               : null,
//         );

//       case 'EARLY_LEAVE':
//         return EarlyLeaveRule(
//           type: ruleType,
//           earlyLeaveMinute: int.tryParse(thresholdMinute ?? '') ?? 0,
//           earlyLeaveAmount: amount?.isNotEmpty == true
//               ? int.tryParse(amount!)
//               : null,
//           earlyLeavePercent: percent?.isNotEmpty == true
//               ? int.tryParse(percent!)
//               : null,
//         );

//       case 'OVERTIME':
//         return OvertimeRule(
//           type: ruleType,
//           overtimeMinute: thresholdMinute?.isNotEmpty == true
//               ? int.tryParse(thresholdMinute!)
//               : null,
//           overtimeAmount: amount?.isNotEmpty == true
//               ? int.tryParse(amount!)
//               : null,
//           overtimeAmountPercent: percent?.isNotEmpty == true
//               ? int.tryParse(percent!)
//               : null,
//           overtimeDay: thresholdDay?.isNotEmpty == true
//               ? int.tryParse(thresholdDay!)
//               : null,
//         );

//       case 'LEAVE_ALLOW':
//         return LeaveRule(
//           type: ruleType,
//           leaveAllowDay: int.tryParse(thresholdDay ?? '') ?? 0,
//         );

//       default:
//         throw Exception("Invalid Rule Type");
//     }
//   }
// }
