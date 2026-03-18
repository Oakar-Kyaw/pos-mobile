import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/component/accent-bar.dart';
import 'package:pos/component/delete-icon.dart';
import 'package:pos/localization/attendance-local.dart';
import 'package:pos/models/attendance.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/badge.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AttendanceCard extends StatelessWidget {
  AttendanceCard({
    super.key,
    required this.textColor,
    required this.subColor,
    required this.attendance,
    this.onDelete,
    //required this.pagingController,
  });

  final Color textColor;
  final Color subColor;
  final Attendance attendance;
  final VoidCallback? onDelete;
  // final PagingController<int, Attendance> pagingController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccentBar(hasDebt: false),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AttendanceHeader(attendance: attendance),
                      const SizedBox(height: 20),
                      Text(attendance.user!.email),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: subColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'dd MMM yyyy EEEE',
                            ).format(attendance.date),
                            style: TextStyle(
                              fontSize: FontSizeConfig.body(context),
                              color: subColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          RowWidget(
                            title: AttendanceLocaleScreenLocale
                                .attendanceCheckIn
                                .getString(context),
                            time: attendance.checkIn.toString(),
                            textColor: textColor,
                          ),
                          const Spacer(),
                          RowWidget(
                            title: AttendanceLocaleScreenLocale
                                .attendanceCheckOut
                                .getString(context),
                            time: attendance.checkOut.toString(),
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (onDelete != null) DeleteIcon(onDelete: onDelete),
      ],
    );
  }
}

class RowWidget extends StatelessWidget {
  const RowWidget({
    super.key,
    required this.textColor,
    required this.title,
    required this.time,
  });

  final String title;
  final String time;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title),
        Text(" : "),
        Text(
          time,
          style: TextStyle(
            fontSize: FontSizeConfig.title(context),
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

String formatToHour(int minutes) {
  final hours = minutes ~/ 60;
  final mins = minutes % 60;

  return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
}

Color getColorByAttendanceStatus(String status) {
  switch (status) {
    case "ABSENT":
      return kRed;

    case "PRESENT":
      return kGreen;

    case "HALF_DAY":
      return Colors.orange;

    case "LEAVE":
      return Colors.blue;

    case "HOLIDAY":
      return kPrimary;

    default:
      return Colors.grey;
  }
}

class AttendanceHeader extends StatelessWidget {
  AttendanceHeader({super.key, required this.attendance});

  final Attendance attendance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BadgeWidget(
          icon: Icons.person,
          label: attendance.status,
          color: getColorByAttendanceStatus(attendance.status),
        ),
        SizedBox(width: 8),
        attendance.isLate
            ? BadgeWidget(
                icon: Icons.warning,
                label: AttendanceLocaleScreenLocale.attendanceLate.getString(
                  context,
                ),
                color: kPrimary,
              )
            : SizedBox(),
        SizedBox(width: 8),
        attendance.isEarlyLeave
            ? BadgeWidget(
                icon: Icons.exit_to_app,
                label: AttendanceLocaleScreenLocale.attendanceEarlyLeave
                    .getString(context),
                color: kSurfaceDark,
              )
            : SizedBox(),
        attendance.overtimeType == 'MINUTES'
            ? Row(
                children: [
                  Text(
                    AttendanceLocaleScreenLocale.attendanceOvertime.getString(
                      context,
                    ),
                  ),
                  const SizedBox(width: 10),
                  BadgeWidget(
                    icon: Icons.lock_clock,
                    label: formatToHour(attendance.overtimeMinutes),
                    color: kSurfaceDark,
                  ),
                ],
              )
            : SizedBox(),

        attendance.overtimeType == 'DAY'
            ? Row(
                children: [
                  Text(
                    AttendanceLocaleScreenLocale.attendanceOvertime.getString(
                      context,
                    ),
                  ),
                  const SizedBox(width: 10),
                  BadgeWidget(
                    icon: Icons.punch_clock,
                    label: AttendanceLocaleScreenLocale.attendanceDay.getString(
                      context,
                    ),
                    color: kSurfaceDark,
                  ),
                ],
              )
            : SizedBox(),

        SizedBox(width: 8),
      ],
    );
  }
}
