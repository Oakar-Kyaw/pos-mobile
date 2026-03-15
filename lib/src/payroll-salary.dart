import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/payroll-local.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/ui/payroll-list.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/description-widget.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PayrollSalaryPage extends ConsumerStatefulWidget {
  const PayrollSalaryPage({super.key});

  @override
  ConsumerState<PayrollSalaryPage> createState() => _PayrollSalaryPageState();
}

class _PayrollSalaryPageState extends ConsumerState<PayrollSalaryPage> {
  int? _filterUserId;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userStateProvider);
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
        title: PayrollLocaleScreenLocale.payrollTitle.getString(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAdmin(user!.role) || isManager(user.role)) ...[
              DescriptionWidget(
                isDark: isDark,
                description: PayrollLocaleScreenLocale.payrollDescription
                    .getString(context),
                icon: LucideIcons.banknote,
                subColor: subColor,
              ),

              const SizedBox(height: 20),

              GradientSubmitButton(
                onPressed: () => context.pushNamed(AppRoute.payrollCreate),
                text: DrawerScreenLocale.drawerCreate.getString(context),
                width: 120,
              ),
            ],
            const SizedBox(height: 20),

            Expanded(
              child: PayrollList(
                userId: _filterUserId,
                fromDate: _fromDate,
                toDate: _toDate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
