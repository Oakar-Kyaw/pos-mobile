import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/attendance.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/attendance-local.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/ui/attendance-list.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/description-widget.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  bool isCheckIn = true;
  Future<void> submitAttendance() async {
    final date = DateTime.now();

    await ref
        .read(attendanceProvider.notifier)
        .createCheckIn(
          date: date,
          checkIn:
              "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}",
        )
        .then((v) {
          if (v["success"]) {
            ShowToast(
              context,
              description: Text(
                AttendanceLocaleScreenLocale.attendanceSuccess.getString(
                  context,
                ),
                style: TextStyle(fontSize: FontSizeConfig.title(context)),
              ),
            );
            setState(() {
              isCheckIn = false;
            });
          } else {
            ShowToast(
              context,
              description: Text(
                AttendanceLocaleScreenLocale.attendanceFail.getString(context),
                style: TextStyle(fontSize: FontSizeConfig.title(context)),
              ),
            );
          }
        });
  }

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
        title: AttendanceLocaleScreenLocale.attendanceTitle.getString(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DescriptionWidget(
              isDark: isDark,
              description: AttendanceLocaleScreenLocale.attendanceDescription
                  .getString(context),
              icon: LucideIcons.clock,
              subColor: subColor,
            ),

            const SizedBox(height: 20),

            GradientSubmitButton(
              onPressed: () => context.pushNamed(AppRoute.attendanceCreate),
              text: DrawerScreenLocale.drawerCreate.getString(context),
              width: 120,
            ),

            const SizedBox(height: 20),
            isCheckIn
                ? GradientSubmitButton(
                    onPressed: submitAttendance,
                    text: AttendanceLocaleScreenLocale.attendanceCheckIn
                        .getString(context),
                    width: 120,
                  )
                : GradientSubmitButton(
                    onPressed: submitAttendance,
                    text: AttendanceLocaleScreenLocale.attendanceCheckOut
                        .getString(context),
                    width: 150,
                  ),
            SizedBox(height: 20),
            const Expanded(child: AttendanceList()),
          ],
        ),
      ),
    );
  }
}
