import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/date-select.dart';
import 'package:pos/component/user-select.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/ui/voucher-list.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/description-widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VoucherCardPage extends ConsumerStatefulWidget {
  const VoucherCardPage({super.key});

  @override
  ConsumerState<VoucherCardPage> createState() => _VoucherCardPageState();
}

class _VoucherCardPageState extends ConsumerState<VoucherCardPage> {
  String searchQuery = "";
  final int limit = 20;

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
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final user = ref.watch(userStateProvider);
    final selectedData = ref.watch(selectedDataStateProvider);
    //print("user dAta🤬: ${selectedData?.userId}");
    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: DrawerScreenLocale.drawerVoucher.getString(context),
      ),
      body: Column(
        children: [
          // Description banner
          if (user != null && (isAdmin(user.role) || isManager(user.role)))
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: DescriptionWidget(
                isDark: isDark,
                description: VoucherScreenLocale.viewAllVouchers.getString(
                  context,
                ),
                icon: LucideIcons.ticket,
                subColor: subColor,
              ),
            ),
          const SizedBox(height: 16),

          // Section label
          VoucherLabel(textColor: textColor),

          if (isAdmin(user!.role) || isManager(user.role))
            Padding(
              padding: const EdgeInsets.all(20),
              child: Expanded(child: DateSelect()),
            ),

          const SizedBox(height: 12),
          // Voucher list
          Expanded(
            child: VoucherList(
              userId: selectedData?.userId,
              startDate: selectedData?.startDate,
              endDate: selectedData?.endDate,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Fixed VoucherLabel
class VoucherLabel extends ConsumerWidget {
  const VoucherLabel({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
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
            DrawerScreenLocale.drawerVoucher.getString(context),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.2,
            ),
          ),
          if (isAdmin(user!.role) || isManager(user.role)) ...[
            Spacer(),
            UserSelect(),
          ],
        ],
      ),
    );
  }
}
