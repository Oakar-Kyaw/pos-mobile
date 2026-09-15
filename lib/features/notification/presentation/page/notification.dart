import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/features/notification/presentation/provider/notification-provider.dart';
import 'package:pos/features/notification/presentation/widget/notification-list.dart';
import 'package:pos/localization/notification-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  // Tab index → API's navigationType string
  static const _tabTypes = ['SYSTEM', 'LOW_STOCK', 'PAYMENT'];

  void _markAllReadForCurrentTab(int tabIndex) async {
    await ref
        .read(notificationProvider.notifier)
        .markAllAsRead(navigationType: _tabTypes[tabIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          return Scaffold(
            backgroundColor: isDark ? kBgDark : kBgLight,
            appBar: CustomAppBar(
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(LucideIcons.arrowLeft),
              ),
              title: NotificationScreenLocale.notificationTitle.getString(
                context,
              ),
              actions: [
                IconButton(
                  onPressed: () =>
                      _markAllReadForCurrentTab(tabController.index),
                  icon: const Icon(LucideIcons.checkCheck, size: 20),
                  tooltip: NotificationScreenLocale.markAllAsRead.getString(
                    context,
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(46),
                child: TabBar(
                  indicatorColor: kPrimary,
                  labelColor: textColor,
                  unselectedLabelColor: subColor,
                  tabs: [
                    Tab(
                      icon: const Icon(LucideIcons.bell, size: 16),
                      text: NotificationScreenLocale.tabSystem.getString(
                        context,
                      ),
                    ),
                    Tab(
                      icon: const Icon(LucideIcons.packageX, size: 16),
                      text: NotificationScreenLocale.tabLowStock.getString(
                        context,
                      ),
                    ),
                    Tab(
                      icon: const Icon(LucideIcons.creditCard, size: 16),
                      text: NotificationScreenLocale.tabPayment.getString(
                        context,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: const TabBarView(
              children: [
                NotificationList(navigationType: 'SYSTEM'),
                NotificationList(navigationType: 'LOW_STOCK'),
                NotificationList(navigationType: 'PAYMENT'),
              ],
            ),
          );
        },
      ),
    );
  }
}
