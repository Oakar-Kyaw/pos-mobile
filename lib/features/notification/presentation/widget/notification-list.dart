import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/features/notification/data/model/notification-item-model.dart';
import 'package:pos/features/notification/presentation/provider/notification-provider.dart';
import 'package:pos/features/notification/presentation/widget/notification-card.dart';
import 'package:pos/localization/notification-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NotificationList extends ConsumerStatefulWidget {
  const NotificationList({super.key, required this.navigationType});

  final String navigationType; // "SYSTEM" | "LOW_STOCK" | "PAYMENT"

  @override
  ConsumerState<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends ConsumerState<NotificationList>
    with AutomaticKeepAliveClientMixin {
  late final PagingController<int, NotificationItem> _pagingController;

  final int limit = 20;

  @override
  bool get wantKeepAlive => true; // Keeps tab state alive when switching tabs

  @override
  void initState() {
    super.initState();

    _pagingController = PagingController<int, NotificationItem>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(notificationProvider.notifier)
          .fetchNotifications(
            page: pageKey,
            limit: limit,
            navigationType: widget.navigationType,
          ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void _onTapNotification(NotificationItem notification) async {
    if (!notification.isRead) {
      await ref.read(notificationProvider.notifier).markAsRead(notification.id);
      _pagingController.refresh();
    }

    if (!mounted) return;

    switch (notification.navigationType) {
      case NotificationNavigationType.lowStock:
        context.pushNamed(AppRoute.lowStock);
        break;
      case NotificationNavigationType.payment:
        // Subscription/billing reminder → navigate to subscription page
        context.pushNamed(AppRoute.accountUpgrade);
        break;
      case NotificationNavigationType.system:
        break;
    }
  }

  void _onDelete(NotificationItem notification) async {
    await ref
        .read(notificationProvider.notifier)
        .deleteNotification(notification.id);
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin requirement
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: RefreshIndicator(
        onRefresh: () async {
          _pagingController.refresh();
        },
        child: PagingListener(
          controller: _pagingController,
          builder: (context, state, fetchNextPage) =>
              PagedListView<int, NotificationItem>(
                state: state,
                fetchNextPage: fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate<NotificationItem>(
                  itemBuilder: (context, notification, index) {
                    return NotificationCard(
                      notification: notification,
                      isDark: isDark,
                      onTap: () => _onTapNotification(notification),
                      onDelete: () => _onDelete(notification),
                    );
                  },
                  firstPageProgressIndicatorBuilder: (_) => const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  ),
                  newPageProgressIndicatorBuilder: (_) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(color: kPrimary),
                    ),
                  ),
                  noItemsFoundIndicatorBuilder: (_) => Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.bellOff, size: 40, color: subColor),
                          const SizedBox(height: 10),
                          Text(
                            NotificationScreenLocale.noNotifications.getString(
                              context,
                            ),
                            style: TextStyle(
                              color: subColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NotificationScreenLocale.noNotificationsDesc
                                .getString(context),
                            style: TextStyle(
                              color: subColor.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  firstPageErrorIndicatorBuilder: (_) => Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.alertCircle,
                            size: 40,
                            color: subColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            NotificationScreenLocale.errorLoading.getString(
                              context,
                            ),
                            style: TextStyle(color: subColor, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _pagingController.refresh(),
                            child: Text(
                              NotificationScreenLocale.retry.getString(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
