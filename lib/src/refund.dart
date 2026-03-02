import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/refund-form.dart';
import 'package:pos/component/refund-table.dart';
import 'package:pos/localization/refund-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // ── Description banner ──────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(isDark ? 0.15 : 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: kPrimary.withOpacity(isDark ? 0.3 : 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.dollarSign,
                      color: kPrimary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      RefundLocale.addRefund.getString(context),
                      style: TextStyle(
                        fontSize: FontSizeConfig.body(context),
                        color: subColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // // ── Form Card ────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? kPrimary.withOpacity(0.1)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: RefundForm(),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: Text(
                RefundLocale.refundTable.getString(context),
                style: TextStyle(
                  fontSize: FontSizeConfig.title(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // // ── Table / List ─────────────────────────
            RefundTable(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
