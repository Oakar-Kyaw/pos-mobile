import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/core/utils/date-range-select.dart';
import 'package:pos/core/utils/user-select.dart';
import 'package:pos/features/request-item/presentation/page/request-item-list.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/inventory-management-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/inventory-configuration.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RequestItemPage extends ConsumerStatefulWidget {
  const RequestItemPage({super.key});

  @override
  ConsumerState<RequestItemPage> createState() => _RequestItemPageState();
}

class _RequestItemPageState extends ConsumerState<RequestItemPage> {
  @override
  void dispose() {
    super.dispose();
    _clearSelectedData();
  }

  void _clearSelectedData() {
    ref.read(selectedDataStateProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final user = ref.watch(userStateProvider);
    final selectedData = ref.watch(selectedDataStateProvider);
    final config = InventoryActionConfig('Request', context);
    //print("expire item is ${InventoryActionType.damaged}");
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
            // ── Description Banner ──────────────────
            // DescriptionWidget(
            //   isDark: isDark,
            //   description: config.description,
            //   icon: config.icon,
            //   subColor: subColor,
            // ),

            // const SizedBox(height: 20),
            GradientSubmitButton(
              onPressed: () => context.pushNamed(
                AppRoute.inventoryItem,
                extra: {'type': 'Request'},
              ),
              text: DrawerScreenLocale.drawerCreate.getString(context),
              width: 120,
            ),

            const SizedBox(height: 20),

            RequestLabel(textColor: textColor),
            if (user != null && (isAdmin(user.role) || isManager(user.role)))
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: DateRangeSelect(),
              ),

            Expanded(
              child: RequestItemLists(
                userId: selectedData?.userId,
                startDate: selectedData?.startDate,
                endDate: selectedData?.endDate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestLabel extends ConsumerWidget {
  const RequestLabel({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateProvider);
    return Row(
      children: [
        if (user != null && (isAdmin(user.role) || isManager(user.role))) ...[
          const UserSelect(),
        ],
      ],
    );
  }
}
