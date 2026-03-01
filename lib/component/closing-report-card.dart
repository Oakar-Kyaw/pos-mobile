// ─────────────────────────────────────────────
// 💳 Closing Report Card
// ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/component/theme-divider.dart';
import 'package:pos/localization/sale-report-local.dart';
import 'package:pos/models/dashboard-stats.dart';
import 'package:pos/models/sale-report.dart';
import 'package:pos/src/report-row.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ClosingReportCard extends StatelessWidget {
  final SaleReport report;
  final AsyncValue<DashboardStats> asyncIncome;
  final bool isDark;

  const ClosingReportCard({
    required this.report,
    required this.asyncIncome,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final openingAmount = report.openingAmount ?? 0;
    final closingAmount = report.closingAmount ?? 0;
    final todaySaleAmount = asyncIncome.maybeWhen(
      data: (income) => income.getTodaySale.total,
      orElse: () => 0,
    );
    // print(
    //   "Closing Amount: $openingAmount $closingAmount, Today's Sale: $todaySaleAmount",
    // );
    final total =
        openingAmount +
        closingAmount +
        double.parse(todaySaleAmount.toString());

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
                      LucideIcons.clipboardList,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SaleReportLocale.saleReportClosingReport.getString(
                          context,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        SaleReportLocale.saleReportDailySummary.getString(
                          context,
                        ),
                        style: const TextStyle(
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
                    iconColor: kGreen,
                    label: SaleReportLocale.saleReportOpeningAmount.getString(
                      context,
                    ),
                    amount: openingAmount.toString(),
                    isPositive: true,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.lockKeyhole,
                    iconColor: kAmber,
                    label: SaleReportLocale.saleReportClosingAmount.getString(
                      context,
                    ),
                    amount: total.toString(),
                    isPositive: false,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  asyncIncome.when(
                    data: (income) => ReportRow(
                      icon: LucideIcons.trendingUp,
                      iconColor: kPrimary,
                      label: SaleReportLocale.saleReportTodaySales.getString(
                        context,
                      ),
                      amount: income.getTodaySale.total.toString(),
                      isPositive: true,
                      highlight: true,
                      isDark: isDark,
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kPrimary,
                          ),
                        ),
                      ),
                    ),
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Error: $err',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
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
