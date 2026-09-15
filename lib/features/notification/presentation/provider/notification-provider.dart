import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/core/provider.dart';
import 'package:pos/features/notification/data/model/notification-item-model.dart';

class NotificationAsyncNotifier extends AsyncNotifier<int> {
  late DioService _dio;

  @override
  Future<int> build() async {
    _dio = ref.watch(dioServiceProvider);
    return await getUnreadCount();
  }

  Future<List<NotificationItem>> fetchNotifications({
    required int page,
    required int limit,
    String? navigationType, // "SYSTEM" | "LOW_STOCK" | "PAYMENT"
  }) async {
    final response = await _dio.get(
      "v1/notifications",
      query: {
        "page": page,
        "limit": limit,
        if (navigationType != null) "navigationType": navigationType,
      },
    );
    final Map<String, dynamic> data = response.data;
    if (data["success"] == true) {
      final List list = data["data"];
      return list.map((e) => NotificationItem.fromJson(e)).toList();
    }
    throw Exception("Failed to fetch notifications");
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get("v1/notifications/unread-count");
    final Map<String, dynamic> data = response.data;
    if (data["success"] == true) {
      return data["data"]["count"] ?? 0;
    }
    return 0;
  }

  Future<bool> markAsRead(int id) async {
    final response = await _dio.patch("v1/notifications/$id/read");
    final Map<String, dynamic> data = response.data;
    if (data["success"] == true) {
      ref.invalidateSelf();
      return true;
    }
    throw Exception("Failed to mark notification as read");
  }

  Future<bool> markAllAsRead({String? navigationType}) async {
    final response = await _dio.patch(
      "v1/notifications/read-all",
      data: {if (navigationType != null) "navigationType": navigationType},
    );
    final Map<String, dynamic> data = response.data;
    if (data["success"] == true) {
      ref.invalidateSelf();
      return true;
    }
    throw Exception("Failed to mark all as read");
  }

  Future<bool> deleteNotification(int id) async {
    final response = await _dio.delete("v1/notifications/$id");
    final Map<String, dynamic> data = response.data;
    if (data["success"] == true) {
      return true;
    }
    throw Exception("Failed to delete notification");
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationAsyncNotifier, int>(
      NotificationAsyncNotifier.new,
    );
