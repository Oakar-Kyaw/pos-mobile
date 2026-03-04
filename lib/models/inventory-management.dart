import 'package:pos/models/inventory-item.dart';

class InventoryManagement {
  final int? id;
  final String type;

  final String? reason;
  final String? note;

  final double totalAmount;

  final int userId;
  final int companyId;
  final int? branchId;

  final bool confirmed;

  final List<InventoryItem> items;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  InventoryManagement({
    this.id,
    required this.type,
    this.reason,
    this.note,
    required this.totalAmount,
    required this.userId,
    required this.companyId,
    this.branchId,
    this.confirmed = false,
    required this.items,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  factory InventoryManagement.fromJson(Map<String, dynamic> json) {
    return InventoryManagement(
      id: json['id'],
      type: json["type"],
      reason: json['reason'],
      note: json['note'],
      totalAmount: double.parse(json['totalAmount'].toString()),
      userId: json['userId'],
      companyId: json['companyId'],
      branchId: json['branchId'],
      confirmed: json['confirmed'] ?? false,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((e) => InventoryItem.fromJson(e))
                .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "reason": reason,
      "note": note,
      "totalAmount": totalAmount,
      "userId": userId,
      "companyId": companyId,
      "branchId": branchId,
      "confirmed": confirmed,
      "items": items.map((e) => e.toJson()).toList(),
    };
  }

  InventoryManagement copyWith({
    int? id,
    String? type,
    String? reason,
    String? note,
    double? totalAmount,
    int? userId,
    int? companyId,
    int? branchId,
    bool? confirmed,
    List<InventoryItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return InventoryManagement(
      id: id ?? this.id,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      note: note ?? this.note,
      totalAmount: totalAmount ?? this.totalAmount,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      confirmed: confirmed ?? this.confirmed,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  static List<InventoryManagement> listFromJson(List<dynamic> data) =>
      data.map((e) => InventoryManagement.fromJson(e)).toList();
}
