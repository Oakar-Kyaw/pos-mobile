import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/employee-local.dart';
import 'package:pos/ui/employee-form.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/description-widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EmployeeCreatePage extends ConsumerWidget {
  const EmployeeCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    //print("type of item 🤬 is $type");
    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: EmployeeLocaleScreenLocale.employeeTitle.getString(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
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

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: EmployeeManagementForm(),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
