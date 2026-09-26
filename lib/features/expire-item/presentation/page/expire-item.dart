import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/core/utils/date-range-select.dart';
import 'package:pos/core/utils/user-select.dart';
import 'package:pos/features/expire-item/presentation/widget/expire-item-list.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/models/inventory-management.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/inventory-configuration.dart';
import 'package:pos/utils/responsive.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ExpireItemsPage extends ConsumerStatefulWidget {
  const ExpireItemsPage({super.key});

  @override
  ConsumerState<ExpireItemsPage> createState() => _ExpireItemsPageState();
}

class _ExpireItemsPageState extends ConsumerState<ExpireItemsPage> {
  late final PagingController<int, InventoryManagement> _pagingController;
  final limit = 20;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, InventoryManagement>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) {
        final selectedData = ref.read(selectedDataStateProvider);
        return ref
            .read(productProvider.notifier)
            .getExpireDamageRequestList(
              page: pageKey,
              limit: limit,
              type: "EXPIRED",
              userId: selectedData?.userId,
              startDate: selectedData?.startDate,
              endDate: selectedData?.endDate,
            );
      },
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void _onCreate() async {
    final result = await context.pushNamed(
      AppRoute.inventoryItem,
      extra: {'type': 'Damage'},
    );

    if (result == true && mounted) {
      _pagingController.refresh();
    }
  }

  void _clearSelectedData() {
    ref.read(selectedDataStateProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final user = ref.watch(userStateProvider);
    final selectedData = ref.watch(selectedDataStateProvider);
    final config = InventoryActionConfig('Damage', context);
    final isWide =
        Responsive.isTablet(context) || Responsive.isDesktop(context);
    final isAdminOrManager =
        user != null && (isAdmin(user.role) || isManager(user.role));

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) => _clearSelectedData(),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: CustomAppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(LucideIcons.arrowLeft),
          ),
          title: config.title,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              GradientSubmitButton(
                onPressed: _onCreate,
                text: DrawerScreenLocale.drawerCreate.getString(context),
                width: 150,
              ),

              const SizedBox(height: 20),

              if (isAdminOrManager)
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: UserSelect()),
                          const SizedBox(width: 16),
                          const Expanded(child: DateRangeSelect()),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: double.infinity,
                            child: UserSelect(),
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(
                            width: double.infinity,
                            child: DateRangeSelect(),
                          ),
                        ],
                      ),
              const SizedBox(height: 10),
              Expanded(
                child: ExpireDamageLists(
                  pagingController: _pagingController,
                  selectedData: selectedData,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
