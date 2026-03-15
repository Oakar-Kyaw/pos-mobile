import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/attendance.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/localization/attendance-local.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/hr-rule-local.dart';
import 'package:pos/localization/payroll-local.dart';
import 'package:pos/ui/attendance-list.dart';
import 'package:pos/ui/hr-rule-form.dart';
import 'package:pos/ui/hr-rule-list.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/description-widget.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HrRulePage extends ConsumerStatefulWidget {
  const HrRulePage({super.key});

  @override
  ConsumerState<HrRulePage> createState() => _HrRulePageState();
}

class _HrRulePageState extends ConsumerState<HrRulePage> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final todayAttendance = ref.watch(todayAttendanceProvider);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: HrRuleLocaleScreen.hrRuleTitle.getString(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DescriptionWidget(
                isDark: isDark,
                description: HrRuleLocaleScreen.hrRuleDescription.getString(
                  context,
                ),
                icon: LucideIcons.clipboardCheck,
                subColor: subColor,
              ),

              const SizedBox(height: 20),

              HrRuleForm(),

              const SizedBox(height: 20),

              HrRuleList(),
            ],
          ),
        ),
      ),
    );
  }
}
