import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/component/attendance-card.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/attendance.dart';
import 'package:pos/utils/app-theme.dart';

class AttendanceListByUserId extends ConsumerStatefulWidget {
  final List<Attendance> attendanceList;

  const AttendanceListByUserId({super.key, required this.attendanceList});

  @override
  ConsumerState<AttendanceListByUserId> createState() => AttendanceListState();
}

class AttendanceListState extends ConsumerState<AttendanceListByUserId> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    final rowHoverColor = isDark
        ? kPrimary.withOpacity(0.06)
        : kPrimary.withOpacity(0.04);

    if (widget.attendanceList.isEmpty) {
      return Center(
        child: Text(VoucherScreenLocale.noItems.getString(context)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.attendanceList.length,
      itemBuilder: (context, index) {
        final attendance = widget.attendanceList[index];

        return InkWell(
          splashColor: kPrimary.withOpacity(0.08),
          highlightColor: rowHoverColor,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: AttendanceCard(
              textColor: textColor,
              subColor: subColor,
              attendance: attendance,
            ),
          ),
        );
      },
    );
  }
}
