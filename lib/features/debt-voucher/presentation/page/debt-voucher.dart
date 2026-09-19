import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/core/utils/date-range-select.dart';
import 'package:pos/core/utils/user-select.dart';
import 'package:pos/features/debt-voucher/presentation/page/debt-list.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/localization/debt-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DebtVoucherPage extends ConsumerStatefulWidget {
  const DebtVoucherPage({super.key});

  @override
  ConsumerState<DebtVoucherPage> createState() => _DebtVoucherPageState();
}

class _DebtVoucherPageState extends ConsumerState<DebtVoucherPage> {
  @override
  void dispose() {
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
    final selectedData = ref.watch(selectedDataStateProvider);
    final user = ref.watch(userStateProvider);

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
          title: DebtLocaleScreenLocale.debtTitle.getString(context),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            if (user != null && (isAdmin(user.role) || isManager(user.role)))
              SizedBox(
                width: double.infinity,
                child: DebtLabel(textColor: textColor),
              ),
            const SizedBox(height: 12),
            // if (user != null && (isAdmin(user.role) || isManager(user.role)))
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(width: double.infinity, child: DateRangeSelect()),
            ),
            Expanded(
              child: DebtListTile(
                userId: selectedData?.userId,
                startDate: selectedData?.startDate,
                endDate: selectedData?.endDate,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class DebtLabel extends ConsumerWidget {
  const DebtLabel({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const UserSelect(),
    );
  }
}
