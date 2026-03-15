import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/ui/debt-list.dart';
import 'package:pos/localization/debt-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DebtVoucherPage extends ConsumerStatefulWidget {
  const DebtVoucherPage({super.key});

  @override
  ConsumerState<DebtVoucherPage> createState() => _DebtVoucherPageState();
}

class _DebtVoucherPageState extends ConsumerState<DebtVoucherPage> {
  final int limit = 20;
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final user = ref.watch(userStateProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: DebtLocaleScreenLocale.debtTitle.getString(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: Column(
                children: [
                  if (isAdmin(user!.role) || isManager(user.role)) ...[
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
                          const Icon(LucideIcons.fileText, color: kPrimary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              DebtLocaleScreenLocale.debtDescription.getString(
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
                        DebtLocaleScreenLocale.debtCard.getString(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  //const SizedBox(height: 16),
                ],
              ),
            ),
            SizedBox(height: 5),
            Expanded(child: DebtListTile()),
          ],
        ),
      ),
    );
  }
}
