import 'package:pos/features/leave/domain/entites/leave.dart';
import 'package:pos/models/user.dart';

class LeaveModel extends Leave {
  LeaveModel({
    required super.id,
    required super.userId,
    required super.user,
    super.approvedId,
    super.approveUser,
    required super.companyId,
    super.branchId,
    required super.date,
    required super.title,
    required super.status,
    super.imageUrl,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
  });

  // FROM JSON
  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'],
      userId: json['userId'],
      user: User.fromJson(json["user"]),
      approvedId: json['approvedId'],
      approveUser: User.fromJson(json["approveUser"]),
      companyId: json['companyId'],
      branchId: json['branchId'],
      date: DateTime.parse(json['date']),
      title: json['title'],

      status: json['status'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "approvedId": approvedId,
      "companyId": companyId,
      "branchId": branchId,
      "date": date.toIso8601String(),
      "title": title,
      "status": status.toUpperCase(),
      "imageUrl": imageUrl,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "isDeleted": isDeleted,
    };
  }

  // 🔄 LIST
  static List<LeaveModel> listFromJson(List<dynamic> list) {
    return list.map((e) => LeaveModel.fromJson(e)).toList();
  }
}
