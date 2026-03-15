import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/repay-local.dart';
import 'package:pos/ui/repay-list.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RepaymentHistoryPage extends ConsumerStatefulWidget {
  const RepaymentHistoryPage({super.key});

  @override
  ConsumerState<RepaymentHistoryPage> createState() =>
      _RepaymentHistoryPageState();
}

class _RepaymentHistoryPageState extends ConsumerState<RepaymentHistoryPage> {
  final int limit = 20;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: RepayLocaleScreen.repayHistoryCard.getString(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: Column(
                children: [
                  // Description banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(isDark ? 0.15 : 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: kPrimary.withOpacity(isDark ? 0.3 : 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.wallet, color: kPrimary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            RepayLocaleScreen.repayDescription.getString(
                              context,
                            ),
                            style: TextStyle(color: subColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      RepayLocaleScreen.repayHistoryCard.getString(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),
            Expanded(child: RepaymentList()),
          ],
        ),
      ),
    );
  }
}
