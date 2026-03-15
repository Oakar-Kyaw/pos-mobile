import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/component/theme-divider.dart';
import 'package:pos/localization/payroll-local.dart';
import 'package:pos/models/payroll.dart';
import 'package:pos/src/report-row.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PaymentCalculationCard extends StatelessWidget {
  final CalculateSalaryData data;
  final bool isDark;

  const PaymentCalculationCard({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bodyColor = isDark ? kSurfaceDark : kSurfaceLight;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFF3F4F6);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(isDark ? 0.2 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // ── Gradient header ──────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimary, kSecondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.calculator,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PayrollLocaleScreenLocale.payrollCalculationTitle
                            .getString(context),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        PayrollLocaleScreenLocale.payrollCalculationSubtitle
                            .getString(context),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────
            Container(
              color: bodyColor,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ReportRow(
                    icon: LucideIcons.walletMinimal,
                    iconColor: kPrimary,
                    label: PayrollLocaleScreenLocale.payrollTotalSalary
                        .getString(context),
                    amount: data.totalSalary.toString(),
                    isPositive: true,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.calendarDays,
                    iconColor: kAmber,
                    label: PayrollLocaleScreenLocale.payrollSalaryByDay
                        .getString(context),
                    amount: data.salaryByDay.toString(),
                    isPositive: true,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.checkCheck,
                    iconColor: kGreen,
                    label: PayrollLocaleScreenLocale.payrollAttendanceSalary
                        .getString(context),
                    amount: data.attendanceSalary.toString(),
                    isPositive: true,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.briefcase,
                    iconColor: kPrimary,
                    label: PayrollLocaleScreenLocale.payrollWorkedDays
                        .getString(context),
                    amount: data.workedDays.toString(),
                    isPositive: true,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.timerOff,
                    iconColor: kRed,
                    label: PayrollLocaleScreenLocale.payrollLateDeduction
                        .getString(context),
                    amount: data.lateDeduction.toString(),
                    isPositive: false,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.logOut,
                    iconColor: kRed,
                    label: PayrollLocaleScreenLocale.payrollEarlyLeaveDeduction
                        .getString(context),
                    amount: data.earlyLeaveDeduction.toString(),
                    isPositive: false,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.userMinus,
                    iconColor: kRed,
                    label: PayrollLocaleScreenLocale.payrollAbsentDeduction
                        .getString(context),
                    amount: data.absentDeduction.toString(),
                    isPositive: false,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.calendarMinus,
                    iconColor: kRed,
                    label: PayrollLocaleScreenLocale.payrollLeaveDeduction
                        .getString(context),
                    amount: data.leaveDeduction.toString(),
                    isPositive: false,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.badgeMinus,
                    iconColor: kRed,
                    label: PayrollLocaleScreenLocale.payrollTotalDeductions
                        .getString(context),
                    amount: data.totalDeductions.toString(),
                    isPositive: false,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.handCoins,
                    iconColor: kGreen,
                    label: PayrollLocaleScreenLocale.payrollNetSalary.getString(
                      context,
                    ),
                    amount: data.netSalary.toString(),
                    isPositive: true,
                    highlight: true,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
