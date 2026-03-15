import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/localization/payroll-local.dart';
import 'package:pos/models/payroll.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/badge.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PayrollCard extends StatelessWidget {
  const PayrollCard({
    super.key,
    required this.payroll,
    required this.textColor,
    required this.subColor,
    required this.isDark,
  });

  final PayrollRecord payroll;
  final Color textColor;
  final Color subColor;
  final bool isDark;

  String _displayName() {
    final first = payroll.user.firstName?.trim() ?? '';
    final last = payroll.user.lastName?.trim() ?? '';
    final full = [first, last].where((e) => e.isNotEmpty).join(' ');
    return full.isNotEmpty ? full : payroll.user.email;
  }

  String _statusLabel(BuildContext context) {
    switch (payroll.status.toUpperCase()) {
      case 'PAID':
        return PayrollLocaleScreenLocale.payrollPaid.getString(context);
      case 'APPROVED':
        return PayrollLocaleScreenLocale.payrollApproved.getString(context);
      case 'DRAFT':
        return PayrollLocaleScreenLocale.payrollDraft.getString(context);
      default:
        return payroll.status;
    }
  }

  Color _statusColor() {
    switch (payroll.status.toUpperCase()) {
      case 'PAID':
        return kGreen;
      case 'APPROVED':
        return kPrimary;
      case 'DRAFT':
        return kAmber;
      default:
        return kTextSubLight;
    }
  }

  IconData _statusIcon() {
    switch (payroll.status.toUpperCase()) {
      case 'PAID':
        return LucideIcons.badgeCheck;
      case 'APPROVED':
        return LucideIcons.check;
      case 'DRAFT':
        return LucideIcons.fileClock;
      default:
        return LucideIcons.info;
    }
  }

  String _formatMoney(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? kSurfaceDark : kSurfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BadgeWidget(
                  icon: _statusIcon(),
                  label: _statusLabel(context).toUpperCase(),
                  color: _statusColor(),
                ),
                const Spacer(),
                Text(
                  DateFormat(
                    'MMM yyyy',
                  ).format(DateTime(payroll.year, payroll.month)),
                  style: TextStyle(
                    fontSize: 12,
                    color: subColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _displayName(),
              style: TextStyle(
                fontSize: FontSizeConfig.title(context),
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              payroll.user.email,
              style: TextStyle(
                fontSize: FontSizeConfig.body(context),
                color: subColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  PayrollLocaleScreenLocale.payrollNetSalary.getString(context),
                  style: TextStyle(fontSize: 12, color: subColor),
                ),
                const Spacer(),
                Text(
                  _formatMoney(payroll.netSalary),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
