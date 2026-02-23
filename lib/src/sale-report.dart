// pages/sale_report_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pos/api/income-dashboard.api.dart';
import 'package:pos/api/sale-report.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/sale-report-local.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SaleReportPage extends ConsumerStatefulWidget {
  const SaleReportPage({super.key});

  @override
  ConsumerState createState() => _SaleReportPageState();
}

class _SaleReportPageState extends ConsumerState<SaleReportPage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(saleReportProvider.notifier).getOpenClosing(date: selectedDate);
      ref.read(incomeProvider.notifier).getIncomesByCompany(date: selectedDate);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      ref.read(saleReportProvider.notifier).getOpenClosing(date: selectedDate);
      ref.read(incomeProvider.notifier).getIncomesByCompany(date: selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncReport = ref.watch(saleReportProvider);
    final asyncIncome = ref.watch(incomeProvider);
    final formattedDate = DateFormat('EEE, dd MMM yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: DrawerScreenLocale.drawerSaleReport.getString(context),
      ),
      body: asyncReport.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (report) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 📅 Date Selector Card
                _DateSelectorCard(
                  formattedDate: formattedDate,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 20),

                // 💳 Main Report Card
                _ClosingReportCard(report: report, asyncIncome: asyncIncome),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 📅 Date Selector Card
// ─────────────────────────────────────────────
class _DateSelectorCard extends StatelessWidget {
  final String formattedDate;
  final VoidCallback onTap;

  const _DateSelectorCard({required this.formattedDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.calendar,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report Date',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Change',
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 💳 Closing Report Card
// ─────────────────────────────────────────────
class _ClosingReportCard extends StatelessWidget {
  final dynamic report;
  final AsyncValue asyncIncome;

  const _ClosingReportCard({required this.report, required this.asyncIncome});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // ── Header with gradient ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Closing Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Daily summary',
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

            // ── Body ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _ReportRow(
                    icon: LucideIcons.walletMinimal,
                    iconColor: const Color(0xFF10B981),
                    label: SaleReportLocale.saleReportOpeningAmount.getString(
                      context,
                    ),
                    amount: report.openingAmount?.toString() ?? '0',
                    isPositive: true,
                  ),
                  const _Divider(),
                  _ReportRow(
                    icon: LucideIcons.lockKeyhole,
                    iconColor: const Color(0xFFF59E0B),
                    label: SaleReportLocale.saleReportClosingAmount.getString(
                      context,
                    ),
                    amount: report.closingAmount?.toString() ?? '0',
                    isPositive: false,
                  ),
                  const _Divider(),
                  asyncIncome.when(
                    data: (income) => _ReportRow(
                      icon: LucideIcons.trendingUp,
                      iconColor: const Color(0xFF6366F1),
                      label: "Today's Sales",
                      amount: income.getTodaySale.total.toString(),
                      isPositive: true,
                      highlight: true,
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
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

// ─────────────────────────────────────────────
// 📊 Report Row
// ─────────────────────────────────────────────
class _ReportRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String amount;
  final bool isPositive;
  final bool highlight;

  const _ReportRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.isPositive,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = _formatAmount(amount);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: highlight
          ? BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            formattedAmount,
            style: TextStyle(
              fontSize: highlight ? 17 : 15,
              fontWeight: FontWeight.w700,
              color: highlight
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(String raw) {
    final number = double.tryParse(raw);
    if (number == null) return raw;
    return NumberFormat('#,##0.00').format(number);
  }
}

// ─────────────────────────────────────────────
// Divider
// ─────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: const Color(0xFFF3F4F6));
  }
}

// ─────────────────────────────────────────────
// Legacy CashWidget (kept for compatibility)
// ─────────────────────────────────────────────
class CashWidget extends StatelessWidget {
  final String title;
  final String amount;

  const CashWidget({super.key, required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
