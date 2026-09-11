// ─────────────────────────────────────────────
// 💳 Closing Report Card
// ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/component/theme-divider.dart';
import 'package:pos/features/sale-report/data/model/sale-report.dart';
import 'package:pos/features/sale-report/presentation/widget/report-row.dart';
import 'package:pos/localization/sale-report-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ClosingReportCard extends StatelessWidget {
  final SaleReport report;
  final bool isDark;

  const ClosingReportCard({
    super.key,
    required this.report,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final openingAmount = report.openingAmount;
    final closingAmount = report.closingAmount;
    final totalGeneralExpense = report.totalGeneralExpense;
    final totalPurchase = report.totalPurchase;
    final totalSaleAmount = report.totalSaleAmount;
    final totalPaidAmount = report.totalPaidAmount;
    final totalDebtAmount = report.totalDebtAmount;
    final totalRefundAmount = report.totalRefundAmount;
    final totalRepayAmount = report.totalRepayAmount;
    final totalTransferAmount = report.totalTransferAmount;
    final totalExternalTransferAmount = report.totalExternalTransferAmount;
    final totalInternalTransferAmount = report.totalInternalTransferAmount;
    final isClosed = report.isClosed;

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.clipboardList,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          SaleReportLocale.saleReportClosingReport.getString(
                            context,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── isClosed badge ────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isClosed ? LucideIcons.lock : LucideIcons.lockOpen,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isClosed
                              ? SaleReportLocale.saleReportClosed.getString(
                                  context,
                                )
                              : SaleReportLocale.saleReportOpen.getString(
                                  context,
                                ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── Body ─────────────────────────────
            Container(
              color: bodyColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    icon: LucideIcons.trendingUp,
                    iconColor: kPrimary,
                    label: SaleReportLocale.saleReportTodaySales.getString(
                      context,
                    ),
                    amount: totalSaleAmount.toString(),
                    isPositive: true,
                    highlight: true,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.banknote,
                    iconColor: kGreen,
                    label: SaleReportLocale.saleReportTotalPaid.getString(
                      context,
                    ),
                    amount: totalPaidAmount.toString(),
                    isPositive: true,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.badgeDollarSign,
                    iconColor: kRed,
                    label: SaleReportLocale.saleReportTotalDebt.getString(
                      context,
                    ),
                    amount: totalDebtAmount.toString(),
                    isPositive: false,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.undo2,
                    iconColor: kRed,
                    label: SaleReportLocale.saleReportTotalRefund.getString(
                      context,
                    ),
                    amount: totalRefundAmount.toString(),
                    isPositive: false,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.handCoins,
                    iconColor: kGreen,
                    label: SaleReportLocale.saleReportTotalRepay.getString(
                      context,
                    ),
                    amount: totalRepayAmount.toString(),
                    isPositive: true,
                    isDark: isDark,
                  ),

                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.receipt,
                    iconColor: kRed,
                    label: SaleReportLocale.saleReportGeneralExpense.getString(
                      context,
                    ),
                    amount: totalGeneralExpense.toString(),
                    isPositive: false,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.shoppingCart,
                    iconColor: kAmber,
                    label: SaleReportLocale.saleReportTotalPurchase.getString(
                      context,
                    ),
                    amount: totalPurchase.toString(),
                    isPositive: false,
                    isDark: isDark,
                  ),

                  // Transfer — internal (doesn't affect closing amount)
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.repeat,
                    iconColor: isDark ? kTextSubDark : kTextSubLight,
                    label: "Internal Transfer Amount",
                    amount: totalInternalTransferAmount.toString(),
                    isPositive: true,
                    isDark: isDark,
                  ),
                  // Transfer — external (reduces closing amount)
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.externalLink,
                    iconColor: kRed,
                    label: "External Transfer Amount",
                    amount: totalExternalTransferAmount.toString(),
                    isPositive: false,
                    isDark: isDark,
                  ),
                  //Transfer (all)
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.arrowLeftRight,
                    iconColor: kAmber,
                    label: SaleReportLocale.saleReportTotalTransfer.getString(
                      context,
                    ),
                    amount: totalTransferAmount.toString(),
                    isPositive: false,
                    isDark: isDark,
                  ),
                  ThemeDivider(color: dividerColor),
                  ReportRow(
                    icon: LucideIcons.lockKeyhole,
                    iconColor: kAmber,
                    label: SaleReportLocale.saleReportClosingAmount.getString(
                      context,
                    ),
                    amount: closingAmount.toString(),
                    isPositive: false,
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
