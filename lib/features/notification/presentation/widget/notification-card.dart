// pos/features/notification/presentation/widget/notification-card.dart

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/features/notification/data/model/notification-item-model.dart';
import 'package:pos/localization/notification-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  final NotificationItem notification;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return kGreen;
      case NotificationType.warning:
        return kAmber;
      case NotificationType.error:
        return kRed;
      case NotificationType.info:
        return kPrimary;
    }
  }

  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return LucideIcons.circleCheck;
      case NotificationType.warning:
        return LucideIcons.triangleAlert;
      case NotificationType.error:
        return LucideIcons.circleX;
      case NotificationType.info:
        return LucideIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final typeColor = _typeColor(notification.type);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: kRed.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(LucideIcons.trash2, color: kRed),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead
                ? surfaceColor
                : typeColor.withOpacity(isDark ? 0.08 : 0.06),
            borderRadius: BorderRadius.circular(14),
            border: notification.isRead
                ? null
                : Border.all(color: typeColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? kPrimary.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _typeIcon(notification.type),
                  color: typeColor,
                  size: 17,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              fontSize: FontSizeConfig.body(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              color: typeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(color: subColor, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notification.readAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "${NotificationScreenLocale.read.getString(context)}: ${DateFormat('dd MMM yyyy, hh:mm a').format(notification.readAt!)}",
                        style: TextStyle(color: subColor, fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
