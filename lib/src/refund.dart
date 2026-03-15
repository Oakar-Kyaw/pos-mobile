import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/refund-card.dart';
import 'package:pos/localization/refund-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
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
            GradientSubmitButton(
              onPressed: () => context.pushNamed(AppRoute.refundCreate),
              text: RefundLocale.refundButton.getString(context),
              width: 150,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(20),
                //   // boxShadow: [
                //   //   BoxShadow(
                //   //     color: isDark
                //   //         ? kPrimary.withOpacity(0.1)
                //   //         : Colors.black.withOpacity(0.06),
                //   //     blurRadius: 12,
                //   //     offset: const Offset(0, 4),
                //   //   ),
                //   // ],
                // ),
                //clipBehavior: Clip.antiAlias,
                child: const RefundCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
