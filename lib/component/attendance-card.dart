import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/component/accent-bar.dart';
import 'package:pos/localization/attendance-local.dart';
import 'package:pos/localization/employee-local.dart';
import 'package:pos/models/attendance.dart';
import 'package:pos/models/user.dart';
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
    required this.pagingController,
  });

  final Color textColor;
  final Color subColor;
  final Attendance attendance;
  PagingController<int, Attendance> pagingController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
                        DateFormat('dd MMM yyyy EEEE').format(attendance.date),
                        style: TextStyle(
                          fontSize: FontSizeConfig.body(context),
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      RowWidget(
                        title: AttendanceLocaleScreenLocale.attendanceCheckIn
                            .getString(context),
                        time: attendance.checkIn.toString(),
                        textColor: textColor,
                      ),
                      Spacer(),
                      RowWidget(
                        title: AttendanceLocaleScreenLocale.attendanceCheckOut
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

class AttendanceHeader extends StatelessWidget {
  AttendanceHeader({super.key, required this.attendance});

  final Attendance attendance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BadgeWidget(icon: Icons.person, label: attendance.status, color: kRed),
        SizedBox(width: 8),
      ],
    );
  }
}

// class SalaryWidget extends StatelessWidget {
//   final String title;
//   final String salary;
//   SalaryWidget({required this.salary, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [Text(title), Spacer(), Text(salary)]);
//   }
// }
