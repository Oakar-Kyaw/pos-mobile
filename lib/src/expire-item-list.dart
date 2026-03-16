import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/date-select.dart';
import 'package:pos/component/user-select.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/inventory-management-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/ui/expire-item-list.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/description-widget.dart';
import 'package:pos/utils/inventory-configuration.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ExpireItemsPage extends ConsumerStatefulWidget {
  const ExpireItemsPage({super.key});

  @override
  ConsumerState<ExpireItemsPage> createState() => _ExpireItemsPageState();
}

class _ExpireItemsPageState extends ConsumerState<ExpireItemsPage> {
  @override
  void dispose() {
    _clearSelectedData();
    super.dispose();
  }

  void _clearSelectedData() {
    ref.read(selectedDataStateProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final user = ref.watch(userStateProvider);
    final selectedData = ref.watch(selectedDataStateProvider);
    final config = InventoryActionConfig('Damage', context);
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
            DescriptionWidget(
              isDark: isDark,
              description: config.description,
              icon: config.icon,
              subColor: subColor,
            ),

            const SizedBox(height: 20),

            GradientSubmitButton(
              onPressed: () =>
                  context.pushNamed(AppRoute.inventoryItem, extra: 'Damage'),
              text: DrawerScreenLocale.drawerCreate.getString(context),
              width: 120,
            ),

            const SizedBox(height: 20),

            ExpireLabel(textColor: textColor),
            if (user != null && (isAdmin(user.role) || isManager(user.role)))
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: DateSelect(),
              ),

            Expanded(child: ExpireDamageLists(selectedData: selectedData)),
          ],
        ),
      ),
    );
  }
}

class ExpireLabel extends ConsumerWidget {
  const ExpireLabel({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateProvider);
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, kSecondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          InventoryManagementLocale.inventoryCard.getString(context),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
        if (user != null && (isAdmin(user.role) || isManager(user.role))) ...[
          const Spacer(),
          const UserSelect(),
        ],
      ],
    );
  }
}
