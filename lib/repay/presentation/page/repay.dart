import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/core/utils/date-range-select.dart';
import 'package:pos/core/utils/user-select.dart';
import 'package:pos/localization/repay-local.dart';
import 'package:pos/repay/presentation/page/repay-list.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RepaymentHistoryPage extends ConsumerStatefulWidget {
  const RepaymentHistoryPage({super.key});

  @override
  ConsumerState<RepaymentHistoryPage> createState() =>
      _RepaymentHistoryPageState();
}

class _RepaymentHistoryPageState extends ConsumerState<RepaymentHistoryPage> {
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
          title: RepayLocaleScreen.repayHistoryCard.getString(context),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (user != null && (isAdmin(user.role) || isManager(user.role)))
              SizedBox(
                width: double.infinity,
                child: RepayLabel(textColor: textColor),
              ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(width: double.infinity, child: DateRangeSelect()),
            ),
            Expanded(
              child: RepaymentList(
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

class RepayLabel extends ConsumerWidget {
  const RepayLabel({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const UserSelect(),
    );
  }
}
