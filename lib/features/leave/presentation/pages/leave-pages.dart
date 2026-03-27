import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/attendance.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/features/leave/presentation/widgets/leave-list.dart';
import 'package:pos/localization/attendance-local.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/leave-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/description-widget.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LeavePage extends ConsumerStatefulWidget {
  const LeavePage({super.key});

  @override
  ConsumerState<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends ConsumerState<LeavePage> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final todayAttendance = ref.watch(todayAttendanceProvider);
    final user = ref.watch(userStateProvider);
    final selectedData = ref.watch(selectedDataStateProvider);
    //print("aaattendacne selected is 📊 ${selectedData?.userId}");
    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: LeaveScreenLocale.leaveTitle.getString(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAdmin(user!.role) || isManager(user.role)) ...[
              DescriptionWidget(
                isDark: isDark,
                description: LeaveScreenLocale.leaveDescription.getString(
                  context,
                ),
                icon: LucideIcons.clock,
                subColor: subColor,
              ),

              const SizedBox(height: 20),

              GradientSubmitButton(
                onPressed: () => context.pushNamed(AppRoute.leaveCreate),
                text: DrawerScreenLocale.drawerCreate.getString(context),
                width: 120,
              ),
            ],

            const SizedBox(height: 20),
            Expanded(child: const Leavelist()),
          ],
        ),
      ),
    );
  }
}
