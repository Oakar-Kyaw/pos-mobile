import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/core/utils/date-range-select.dart';
import 'package:pos/core/utils/user-select.dart';
import 'package:pos/features/refund/presentation/widget/refund-card.dart';
import 'package:pos/localization/refund-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RefundPage extends ConsumerStatefulWidget {
  const RefundPage({super.key});

  @override
  ConsumerState<RefundPage> createState() => _RefundPageState();
}

class _RefundPageState extends ConsumerState<RefundPage> {
  final int limit = 20;
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final user = ref.watch(userStateProvider);
    final selectedData = ref.watch(selectedDataStateProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) =>
          ref.read(selectedDataStateProvider.notifier).clear(),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: CustomAppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(LucideIcons.arrowLeft),
          ),
          title: RefundLocale.refund.getString(context),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAdmin(user!.role) || isManager(user.role)) ...[
                GradientSubmitButton(
                  onPressed: () => context.pushNamed(AppRoute.refundCreate),
                  text: RefundLocale.refundButton.getString(context),
                  width: 150,
                ),
                SizedBox(height: 20),
                UserSelect(),
                SizedBox(height: 20),
              ],
              SizedBox(width: double.infinity, child: DateRangeSelect()),
              const SizedBox(height: 20),
              Expanded(child: RefundCard(selectedData: selectedData)),
            ],
          ),
        ),
      ),
    );
  }
}
