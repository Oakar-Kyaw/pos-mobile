import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/core/utils/date-range-select.dart';
import 'package:pos/core/utils/user-select.dart';
import 'package:pos/features/voucher/presentation/pages/voucher-list.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';

class VoucherCardPage extends ConsumerStatefulWidget {
  const VoucherCardPage({super.key});

  @override
  ConsumerState<VoucherCardPage> createState() => _VoucherCardPageState();
}

class _VoucherCardPageState extends ConsumerState<VoucherCardPage> {
  String searchQuery = "";
  final int limit = 20;
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final user = ref.watch(userStateProvider);
    final selectedData = ref.watch(selectedDataStateProvider);
    //print("user dAta🤬: ${selectedData?.userId}");
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (pop, result) =>
          ref.read(selectedDataStateProvider.notifier).clear(),

      child: Scaffold(
        backgroundColor: bgColor,
        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: DrawerScreenLocale.drawerVoucher.getString(context),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // // Section label
            if (isAdmin(user!.role) || isManager(user.role))
              VoucherLabel(textColor: textColor),
            if (isAdmin(user.role) || isManager(user.role))
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: DateRangeSelect(),
                ),
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
      child: SizedBox(width: double.infinity, child: UserSelect()),
    );
  }
}
