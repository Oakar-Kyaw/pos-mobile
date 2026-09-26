import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/core/utils/date-range-select.dart';
import 'package:pos/core/utils/supplier-select.dart';
import 'package:pos/features/purchase-history/presentation/widget/purchase-item-lists.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/inventory-configuration.dart';
import 'package:pos/utils/responsive.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PurchaseItemPage extends ConsumerStatefulWidget {
  const PurchaseItemPage({super.key});

  @override
  ConsumerState<PurchaseItemPage> createState() => _PurchaseItemPageState();
}

class _PurchaseItemPageState extends ConsumerState<PurchaseItemPage> {
  late final SelectedDataNotifier _selectedDataNotifier;

  @override
  void initState() {
    super.initState();

    _selectedDataNotifier = ref.read(selectedDataStateProvider.notifier);
  }

  @override
  void dispose() {
    debugPrint("PurchaseItemPage disposed 🤩");

    _selectedDataNotifier.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final user = ref.watch(userStateProvider);
    final config = InventoryActionConfig('Purchase', context);
    final selectedData = ref.watch(selectedDataStateProvider);
    final isWide =
        Responsive.isTablet(context) || Responsive.isDesktop(context);
    final isAdminOrManager =
        user != null && (isAdmin(user.role) || isManager(user.role));

    return Scaffold(
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
            GradientSubmitButton(
              onPressed: () => context.pushNamed(AppRoute.purchaseCreate),
              text: DrawerScreenLocale.drawerCreate.getString(context),
              width: 120,
            ),

            const SizedBox(height: 20),

            if (isAdminOrManager)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SupplierSelect(
                              onChanged: (value) {
                                if (value == '' || value == null) {
                                  ref
                                      .read(selectedDataStateProvider.notifier)
                                      .clearSupplier();
                                } else {
                                  ref
                                      .read(selectedDataStateProvider.notifier)
                                      .setSupplierUser(int.tryParse(value)!);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: DateRangeSelect()),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: SupplierSelect(
                              onChanged: (value) {
                                if (value == '' || value == null) {
                                  ref
                                      .read(selectedDataStateProvider.notifier)
                                      .clearSupplier();
                                } else {
                                  ref
                                      .read(selectedDataStateProvider.notifier)
                                      .setSupplierUser(int.tryParse(value)!);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(
                            width: double.infinity,
                            child: DateRangeSelect(),
                          ),
                        ],
                      ),
              ),

            Expanded(child: PurchaseItemLists(selectedData: selectedData)),
          ],
        ),
      ),
    );
  }
}
