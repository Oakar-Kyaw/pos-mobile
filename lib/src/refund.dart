import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/date-select.dart';
import 'package:pos/component/refund-card.dart';
import 'package:pos/component/user-select.dart';
import 'package:pos/localization/refund-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/description-widget.dart';
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
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final user = ref.watch(userStateProvider);
    final selectedData = ref.watch(selectedDataStateProvider);

    return Scaffold(
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
            DescriptionWidget(
              isDark: isDark,
              description: RefundLocale.addRefund.getString(context),
              icon: LucideIcons.dollarSign,
              subColor: subColor,
            ),
            const SizedBox(height: 20),
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
            DateSelect(),
            const SizedBox(height: 20),
            Expanded(child: RefundCard(selectedData: selectedData)),
          ],
        ),
      ),
    );
  }
}
