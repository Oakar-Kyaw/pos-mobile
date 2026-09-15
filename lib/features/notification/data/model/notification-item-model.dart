// pos/features/notification/data/model/notification.dart

enum NotificationType {
  info,
  success,
  warning,
  error;

  static NotificationType fromString(String? value) {
    switch (value) {
      case 'SUCCESS':
        return NotificationType.success;
      case 'WARNING':
        return NotificationType.warning;
      case 'ERROR':
        return NotificationType.error;
      case 'INFO':
      default:
        return NotificationType.info;
    }
  }

  String get value {
    switch (this) {
      case NotificationType.info:
        return 'INFO';
      case NotificationType.success:
        return 'SUCCESS';
      case NotificationType.warning:
        return 'WARNING';
      case NotificationType.error:
        return 'ERROR';
    }
  }
}

enum NotificationNavigationType {
  system,
  lowStock,
  payment;

  static NotificationNavigationType fromString(String? value) {
    switch (value) {
      case 'LOW_STOCK':
        return NotificationNavigationType.lowStock;
      case 'PAYMENT':
        return NotificationNavigationType.payment;
      case 'SYSTEM':
      default:
        return NotificationNavigationType.system;
    }
  }

  String get value {
    switch (this) {
      case NotificationNavigationType.system:
        return 'SYSTEM';
      case NotificationNavigationType.lowStock:
        return 'LOW_STOCK';
      case NotificationNavigationType.payment:
        return 'PAYMENT';
    }
  }
}

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationNavigationType navigationType;
  final int? userId;
  final int? companyId;
  final int? branchId;
  final bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.navigationType,
    required this.isRead,
    this.userId,
    this.companyId,
    this.branchId,
    this.readAt,
    this.data,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: NotificationType.fromString(json['type']),
      navigationType: NotificationNavigationType.fromString(
        json['navigationType'],
      ),
      userId: json['userId'],
      companyId: json['companyId'],
      branchId: json['branchId'],
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }

  static List<NotificationItem> listFromJson(List<dynamic> json) =>
      json.map((e) => NotificationItem.fromJson(e)).toList();

  NotificationItem copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      navigationType: navigationType,
      userId: userId,
      companyId: companyId,
      branchId: branchId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      data: data,
    );
  }
}
