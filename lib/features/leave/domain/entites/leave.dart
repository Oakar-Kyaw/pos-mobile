import 'package:pos/models/user.dart';

class Leave {
  final int id;
  final int userId;
  final int? approvedId;
  final int companyId;
  final int? branchId;

  final DateTime date;
  final String title;
  final String status;
  final String? imageUrl;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final User user;
  final User? approveUser;

  Leave({
    required this.id,
    required this.userId,
    this.approvedId,
    required this.companyId,
    this.branchId,
    required this.date,
    required this.title,
    required this.status,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.user,
    this.approveUser,
  });
}
