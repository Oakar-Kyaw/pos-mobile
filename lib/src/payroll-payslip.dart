import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/payroll.api.dart';
import 'package:pos/api/company.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/pdf-row.dart';
import 'package:pos/component/theme-divider.dart';
import 'package:pos/localization/payroll-local.dart';
import 'package:pos/models/payroll.dart';
import 'package:pos/models/company.dart';
import 'package:pos/models/user.dart';
import 'package:pos/riverpod/company.riverpod.dart';
import 'package:pos/src/report-row.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/badge.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' as printing;
import 'package:shadcn_ui/shadcn_ui.dart';

final payrollByIdProvider = FutureProvider.family<PayrollRecord, int>((
  ref,
  id,
) async {
  final notifier = ref.read(payrollProvider.notifier);
  return await notifier.getPayrollById(id);
});

class PayrollPayslipPage extends ConsumerWidget {
  final int id;

  const PayrollPayslipPage({super.key, required this.id});

  String _displayName(User user) {
    final first = user.firstName?.trim() ?? '';
    final last = user.lastName?.trim() ?? '';
    final full = [first, last].where((e) => e.isNotEmpty).join(' ');
    return full.isNotEmpty ? full : user.email;
  }

  String _formatMoney(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  Future<void> _printPayslip(
    PayrollRecord payroll,
    Company? company,
    BuildContext context,
  ) async {
    print("Company is $company");
    final doc = pw.Document();
    final periodLabel = DateFormat(
      'MMM yyyy',
    ).format(DateTime(payroll.year, payroll.month));

    pw.ImageProvider? logo;
    if (company?.photoUrl != null && company!.photoUrl!.trim().isNotEmpty) {
      try {
        logo = await printing.networkImage(company.photoUrl!);
      } catch (_) {}
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => [
          pw.Text(
            PayrollLocaleScreenLocale.payrollPayslipTitle.getString(context),
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),

          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // if (logo != null)
              //   pw.Container(
              //     width: 52,
              //     height: 52,
              //     margin: const pw.EdgeInsets.only(right: 12),
              //     child: pw.Image(logo!, fit: pw.BoxFit.cover),
              //   ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      company?.name ?? '',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if ((company?.phone ?? '').isNotEmpty)
                      pw.Text('Phone: ${company?.phone ?? ''}'),
                    if ((company?.email ?? '').isNotEmpty)
                      pw.Text('Email: ${company?.email ?? ''}'),
                    if ((company?.address ?? '').isNotEmpty)
                      pw.Text('Address: ${company?.address ?? ''}'),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text('Period: $periodLabel'),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  _displayName(payroll.user),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(payroll.user.email),
                pw.SizedBox(height: 4),
                pw.Text('Status: ${_statusLabel(payroll.status, context)}'),
              ],
            ),
          ),
          if (payroll.note != null && payroll.note!.trim().isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              '${PayrollLocaleScreenLocale.payrollNote.getString(context)}:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(payroll.note!),
          ],
          pw.SizedBox(height: 16),
          pw.Text(
            'Salary Breakdown',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(),
          pdfRow(
            PayrollLocaleScreenLocale.payrollBasicSalary.getString(context),
            _formatMoney(payroll.baseSalary),
            PdfColors.grey300,
          ),
          pdfRow(
            PayrollLocaleScreenLocale.payrollBonus.getString(context),
            _formatMoney(payroll.bonus),
            PdfColors.grey300,
          ),
          pdfRow('Overtime', _formatMoney(payroll.overtime), PdfColors.grey300),
          pdfRow(
            PayrollLocaleScreenLocale.payrollLateDeduction.getString(context),
            _formatMoney(payroll.lateDeduction),
            PdfColors.grey300,
          ),
          pdfRow(
            PayrollLocaleScreenLocale.payrollEarlyLeaveDeduction.getString(
              context,
            ),
            _formatMoney(payroll.earlyLeaveDeduction),
            PdfColors.grey300,
          ),
          pdfRow(
            PayrollLocaleScreenLocale.payrollLeaveDeduction.getString(context),
            _formatMoney(payroll.leaveDeduction),
            PdfColors.grey300,
          ),
          pdfRow(
            PayrollLocaleScreenLocale.payrollDeduction.getString(context),
            _formatMoney(payroll.deduction),
            PdfColors.grey300,
          ),
          pdfRow(
            PayrollLocaleScreenLocale.payrollTotalDeductions.getString(context),
            _formatMoney(payroll.totalDeductions),
            PdfColors.grey300,
            bold: true,
          ),
          pdfRow(
            PayrollLocaleScreenLocale.payrollNetSalary.getString(context),
            _formatMoney(payroll.netSalary),
            PdfColors.grey300,
            bold: true,
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Attendance Summary',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(),
          pdfRow(
            'Present Days',
            payroll.presentDays.toString(),
            PdfColors.grey300,
          ),
          pdfRow(
            'Absent Days',
            payroll.absentDays.toString(),
            PdfColors.grey300,
          ),
          pdfRow('Half Days', payroll.halfDays.toString(), PdfColors.grey300),
          pdfRow('Leave Days', payroll.leaveDays.toString(), PdfColors.grey300),
          pdfRow(
            'Late Minutes',
            payroll.lateTotalMinutes.toString(),
            PdfColors.grey300,
          ),
          pdfRow(
            'Early Leave Minutes',
            payroll.earlyLeaveTotalMinutes.toString(),
            PdfColors.grey300,
          ),
          pdfRow(
            'Overtime Minutes',
            payroll.overtimeTotalMinutes.toString(),
            PdfColors.grey300,
          ),
          pdfRow(
            'Total Working Days',
            payroll.totalWorkingDays.toString(),
            PdfColors.grey300,
          ),
        ],
      ),
    );

    await printing.Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  String _statusLabel(String status, BuildContext context) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return PayrollLocaleScreenLocale.payrollPaid.getString(context);
      case 'APPROVED':
        return PayrollLocaleScreenLocale.payrollApproved.getString(context);
      case 'DRAFT':
        return PayrollLocaleScreenLocale.payrollDraft.getString(context);
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
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

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payrollAsync = ref.watch(payrollByIdProvider(id));
    final company = ref.watch(companyStateProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFF3F4F6);

    print("company async is ${company!.photoUrl}");
    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: PayrollLocaleScreenLocale.payrollPayslipTitle.getString(context),
        actions:
            // payrollAsync.asData?.value == null ||
            //     companyAsync.asData?.value == null
            // ? null
            // :
            [
              IconButton(
                onPressed: () =>
                    _printPayslip(payrollAsync.asData!.value, company, context),
                icon: const Icon(LucideIcons.printer),
              ),
            ],
      ),
      body: payrollAsync.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (payroll) {
          final monthLabel = DateFormat(
            'MMM yyyy',
          ).format(DateTime(payroll.year, payroll.month));

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= HEADER =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                LucideIcons.userRound,
                                color: kPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _displayName(payroll.user),
                                    style: TextStyle(
                                      fontSize: FontSizeConfig.title(context),
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? kTextDark : kTextLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    payroll.user.email,
                                    style: TextStyle(
                                      fontSize: FontSizeConfig.body(context),
                                      color: subColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            BadgeWidget(
                              icon: _statusIcon(payroll.status),
                              label: _statusLabel(
                                payroll.status,
                                context,
                              ).toUpperCase(),
                              color: _statusColor(payroll.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ThemeDivider(color: dividerColor),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 14,
                              color: subColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              monthLabel,
                              style: TextStyle(
                                fontSize: FontSizeConfig.body(context),
                                color: subColor,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "#${payroll.id}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: subColor,
                              ),
                            ),
                          ],
                        ),
                        if (payroll.note != null &&
                            payroll.note!.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            PayrollLocaleScreenLocale.payrollNote.getString(
                              context,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: subColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            payroll.note!,
                            style: TextStyle(
                              fontSize: FontSizeConfig.body(context),
                              color: isDark ? kTextDark : kTextLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================= NET PAY =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [kPrimary, kSecondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PayrollLocaleScreenLocale.payrollNetSalary.getString(
                            context,
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          payroll.netSalary.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================= BREAKDOWN =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        ReportRow(
                          icon: LucideIcons.walletMinimal,
                          iconColor: kPrimary,
                          label: PayrollLocaleScreenLocale.payrollBasicSalary
                              .getString(context),
                          amount: payroll.baseSalary.toString(),
                          isPositive: true,
                          isDark: isDark,
                        ),
                        ThemeDivider(color: dividerColor),
                        ReportRow(
                          icon: LucideIcons.timer,
                          iconColor: kGreen,
                          label: PayrollLocaleScreenLocale.payrollBonus
                              .getString(context),
                          amount: payroll.bonus.toString(),
                          isPositive: true,
                          isDark: isDark,
                        ),
                        ThemeDivider(color: dividerColor),
                        ReportRow(
                          icon: LucideIcons.clock4,
                          iconColor: kAmber,
                          label: 'Overtime',
                          amount: payroll.overtime.toString(),
                          isPositive: true,
                          isDark: isDark,
                        ),
                        ThemeDivider(color: dividerColor),
                        ReportRow(
                          icon: LucideIcons.timerOff,
                          iconColor: kRed,
                          label: PayrollLocaleScreenLocale.payrollLateDeduction
                              .getString(context),
                          amount: payroll.lateDeduction.toString(),
                          isPositive: false,
                          isDark: isDark,
                        ),
                        ThemeDivider(color: dividerColor),
                        ReportRow(
                          icon: LucideIcons.logOut,
                          iconColor: kRed,
                          label: PayrollLocaleScreenLocale
                              .payrollEarlyLeaveDeduction
                              .getString(context),
                          amount: payroll.earlyLeaveDeduction.toString(),
                          isPositive: false,
                          isDark: isDark,
                        ),
                        ThemeDivider(color: dividerColor),
                        ReportRow(
                          icon: LucideIcons.calendarMinus,
                          iconColor: kRed,
                          label: PayrollLocaleScreenLocale.payrollLeaveDeduction
                              .getString(context),
                          amount: payroll.leaveDeduction.toString(),
                          isPositive: false,
                          isDark: isDark,
                        ),
                        ThemeDivider(color: dividerColor),
                        ReportRow(
                          icon: LucideIcons.badgeMinus,
                          iconColor: kRed,
                          label: PayrollLocaleScreenLocale.payrollDeduction
                              .getString(context),
                          amount: payroll.deduction.toString(),
                          isPositive: false,
                          isDark: isDark,
                        ),
                        ThemeDivider(color: dividerColor),
                        ReportRow(
                          icon: LucideIcons.badgeMinus,
                          iconColor: kRed,
                          label: PayrollLocaleScreenLocale
                              .payrollTotalDeductions
                              .getString(context),
                          amount: payroll.totalDeductions.toString(),
                          isPositive: false,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================= ATTENDANCE SUMMARY =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PayrollLocaleScreenLocale.payrollCalculationSubtitle
                              .getString(context),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: subColor,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InfoChip(
                              icon: LucideIcons.calendarCheck,
                              label: payroll.presentDays.toString(),
                              sub: 'Present Days',
                              color: kGreen,
                            ),
                            _InfoChip(
                              icon: LucideIcons.calendarX,
                              label: payroll.absentDays.toString(),
                              sub: 'Absent Days',
                              color: kRed,
                            ),
                            _InfoChip(
                              icon: LucideIcons.calendarClock,
                              label: payroll.halfDays.toString(),
                              sub: 'Half Days',
                              color: kAmber,
                            ),
                            _InfoChip(
                              icon: LucideIcons.calendarMinus,
                              label: payroll.leaveDays.toString(),
                              sub: 'Leave Days',
                              color: kPrimary,
                            ),
                            _InfoChip(
                              icon: LucideIcons.timerOff,
                              label: payroll.lateTotalMinutes.toString(),
                              sub: 'Late Minutes',
                              color: kRed,
                            ),
                            _InfoChip(
                              icon: LucideIcons.logOut,
                              label: payroll.earlyLeaveTotalMinutes.toString(),
                              sub: 'Early Leave Minutes',
                              color: kRed,
                            ),
                            _InfoChip(
                              icon: LucideIcons.timer,
                              label: payroll.overtimeTotalMinutes.toString(),
                              sub: 'Overtime Minutes',
                              color: kGreen,
                            ),
                            _InfoChip(
                              icon: LucideIcons.briefcase,
                              label: payroll.totalWorkingDays.toString(),
                              sub: 'Total Working Days',
                              color: kPrimary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: color.withOpacity(0.8)),
              const SizedBox(width: 4),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: FontSizeConfig.body(context),
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
