import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/employee-local.dart';
import 'package:pos/ui/employee-list.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/description-widget.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EmployeePage extends ConsumerWidget {
  const EmployeePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: EmployeeLocaleScreenLocale.employeeTitle.getString(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Description Banner ──────────────────
            DescriptionWidget(
              isDark: isDark,
              description: EmployeeLocaleScreenLocale.employeeDescription
                  .getString(context),
              icon: Icons.person,
              subColor: subColor,
            ),

            const SizedBox(height: 20),

            GradientSubmitButton(
              onPressed: () => context.pushNamed(AppRoute.employeeCreate),
              text: DrawerScreenLocale.drawerCreate.getString(context),
              width: 120,
            ),
            const SizedBox(height: 20),

            Expanded(child: EmployeeList()),
          ],
        ),
      ),
    );
  }
}
