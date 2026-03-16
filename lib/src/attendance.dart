import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/attendance.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/date-select.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/user-select.dart';
import 'package:pos/localization/attendance-local.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/ui/attendance-list.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/check-role.dart';
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
  final _attendanceListKey = GlobalKey<AttendanceListState>();

  @override
  void dispose() {
    super.dispose();
    _clearSelectedData();
  }

  void _clearSelectedData() {
    ref.read(selectedDataStateProvider.notifier).clear();
  }

  Future<void> submitCheckIn() async {
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
            _attendanceListKey.currentState?.refresh();
            ref.invalidate(todayAttendanceProvider);
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

  Future<void> submitCheckOut() async {
    final date = DateTime.now();

    await ref
        .read(attendanceProvider.notifier)
        .createCheckOut(
          date: date,
          checkOut:
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
            _attendanceListKey.currentState?.refresh();
            ref.invalidate(todayAttendanceProvider);
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
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final todayAttendance = ref.watch(todayAttendanceProvider);
    final user = ref.watch(userStateProvider);
    final selectedData = ref.watch(selectedDataStateProvider);
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
            if (isAdmin(user!.role) || isManager(user.role)) ...[
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
            ],

            const SizedBox(height: 20),

            todayAttendance.when(
              data: (attendance) {
                String buttonText;
                bool isButtonEnabled = true;
                VoidCallback? onPressed;

                if (attendance == null) {
                  // Case 1: no attendance → Check In
                  buttonText = AttendanceLocaleScreenLocale.attendanceCheckIn
                      .getString(context);
                  onPressed = submitCheckIn; // pass the function, don't call it
                } else if (attendance.checkIn != null &&
                    attendance.checkOut == null) {
                  // Case 2: checked in, not checked out → Check Out
                  buttonText = AttendanceLocaleScreenLocale.attendanceCheckOut
                      .getString(context);
                  onPressed = submitCheckOut; // same function handles check-out
                } else {
                  // Case 3: already checked out → disable button
                  buttonText = AttendanceLocaleScreenLocale.attendanceCompleted
                      .getString(context);
                  isButtonEnabled = false;
                  onPressed = () {}; // disables the button
                }

                return isButtonEnabled
                    ? GradientSubmitButton(
                        onPressed: onPressed,
                        text: buttonText,
                        width: 150,
                      )
                    : GradientSubmitButton(
                        onPressed: onPressed,
                        text: buttonText,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: 150,
                      );
              },
              loading: () => LoadingWidget(),
              error: (err, __) => Text(err.toString()),
            ),
            const SizedBox(height: 20),
            AttendanceLabel(textColor: textColor),
            if (isAdmin(user.role) || isManager(user.role))
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: DateSelect(),
              ),
            Expanded(
              child: AttendanceList(
                key: _attendanceListKey,
                userId: selectedData?.userId,
                startDate: selectedData?.startDate,
                endDate: selectedData?.endDate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceLabel extends ConsumerWidget {
  const AttendanceLabel({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateProvider);
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, kSecondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          AttendanceLocaleScreenLocale.attendanceTitle.getString(context),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
        if (user != null && (isAdmin(user.role) || isManager(user.role))) ...[
          const Spacer(),
          const UserSelect(),
        ],
      ],
    );
  }
}
