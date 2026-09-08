import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/income-dashboard.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/features/income/data/model/dashboard-stats.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/income-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/date-ui.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class IncomePage extends ConsumerStatefulWidget {
  const IncomePage({super.key});

  @override
  ConsumerState<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends ConsumerState<IncomePage> {
  DateTime selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);

      ref.read(incomeProvider.notifier).getIncomesByCompany(date: selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final incomeDataAsync = ref.watch(incomeProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final formattedDate = DateFormat('dd MMM yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: DrawerScreenLocale.drawerIncome.getString(context),
      ),
      body: incomeDataAsync.when(
        data: (data) => _buildBody(context, formattedDate, data, isDark),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: TextStyle(color: isDark ? kTextSubDark : Colors.black54),
          ),
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: kPrimary)),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    String formattedDate,
    DashboardStats data,
    bool isDark,
  ) {
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateSelectorCard(
            formattedDate: formattedDate,
            onTap: _pickDate,
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: IncomeScreenLocale.incomeMonthlyRevenue.getString(context),
            textColor: textColor,
          ),
          const SizedBox(height: 14),
          _MonthlyBarChart(monthlyData: data.getMonthByMonth, isDark: isDark),

          SizedBox(height: 20),
          Text(
            IncomeScreenLocale.incomeOverview.getString(context),
            style: TextStyle(
              color: subColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),

          // ── Today ──────────────────────────────────────
          _StatCard(
            label: IncomeScreenLocale.incomeToday.getString(context),
            netIncome: data.getTodaySale.netIncome,
            taxValue: data.getTodaySale.tax,
            deliveryFeeValue: data.getTodaySale.deliveryFee,
            packagingFeeValue: data.getTodaySale.packagingFee,
            discountAmount: data.getTodaySale.discountAmount,
            discountPercent: data.getTodaySale.discountPercent,
            refundAmount: data.getTodaySale.refundAmount,
            debtAmount: data.getTodaySale.debtAmount,
            expenseAmount: data.getTodaySale.expenseAmount,
            purchaseAmount: data.getTodaySale.purchaseAmount,
            totalPaymentAmount: data.getTodaySale.totalPaymentAmount,
            total: data.getTodaySale.total,
            sub:
                '${IncomeScreenLocale.incomeTax.getString(context)} ${formatAmount(double.tryParse(data.getTodaySale.tax) ?? 0)}  •  ${IncomeScreenLocale.incomeFee.getString(context)} ${formatAmount(double.tryParse(data.getTodaySale.deliveryFee) ?? 0)}',
            dark: true,
            icon: Icons.trending_up_rounded,
            fullWidth: true,
          ),
          const SizedBox(height: 12),

          // ── This Month ─────────────────────────────────
          _StatCard(
            label: IncomeScreenLocale.incomeThisMonth.getString(context),
            netIncome: data.monthlySale.netIncome,
            taxValue: data.monthlySale.tax,
            deliveryFeeValue: data.monthlySale.deliveryFee,
            packagingFeeValue: data.monthlySale.packagingFee,
            discountAmount: data.monthlySale.discountAmount,
            discountPercent: data.monthlySale.discountPercent,
            refundAmount: data.monthlySale.refundAmount,
            debtAmount: data.monthlySale.debtAmount,
            expenseAmount: data.monthlySale.expenseAmount,
            purchaseAmount: data.monthlySale.purchaseAmount,
            totalPaymentAmount: data.monthlySale.totalPaymentAmount,
            total: data.monthlySale.total,
            sub:
                '${IncomeScreenLocale.incomeTax.getString(context)} ${formatAmount(double.tryParse(data.monthlySale.tax) ?? 0)}  •  ${IncomeScreenLocale.incomeFee.getString(context)} ${formatAmount(double.tryParse(data.monthlySale.deliveryFee) ?? 0)}',
            dark: false,
            isDark: isDark,
            icon: Icons.calendar_today_rounded,
          ),

          const SizedBox(height: 20),

          // ── This Year ──────────────────────────────────
          _StatCard(
            label: IncomeScreenLocale.incomeThisYear.getString(context),
            netIncome: data.yearlySale.netIncome,
            taxValue: data.yearlySale.tax,
            deliveryFeeValue: data.yearlySale.deliveryFee,
            packagingFeeValue: data.yearlySale.packagingFee,
            discountAmount: data.yearlySale.discountAmount,
            discountPercent: data.yearlySale.discountPercent,
            refundAmount: data.yearlySale.refundAmount,
            debtAmount: data.yearlySale.debtAmount,
            expenseAmount: data.yearlySale.expenseAmount,
            purchaseAmount: data.yearlySale.purchaseAmount,
            totalPaymentAmount: data.yearlySale.totalPaymentAmount,
            total: data.yearlySale.total,
            sub:
                '${IncomeScreenLocale.incomeTax.getString(context)} ${formatAmount(double.tryParse(data.yearlySale.tax) ?? 0)}  •  ${IncomeScreenLocale.incomeFee.getString(context)} ${formatAmount(double.tryParse(data.yearlySale.deliveryFee) ?? 0)}',
            dark: true,
            icon: Icons.trending_up_rounded,
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _ItemRankCard(
                  title: IncomeScreenLocale.incomeTopSeller.getString(context),
                  icon: Icons.local_fire_department_rounded,
                  dark: true,
                  isDark: isDark,
                  items: data.mostSellingItem,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ItemRankCard(
                  title: IncomeScreenLocale.incomeLeastSold.getString(context),
                  icon: Icons.arrow_downward_rounded,
                  dark: false,
                  isDark: isDark,
                  items: data.leastSellingItem,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _SectionHeader(
            title: IncomeScreenLocale.incomeTopSalesStaff.getString(context),
            textColor: textColor,
          ),
          const SizedBox(height: 12),
          ...data.getMonthlyTopSaleUser.map(
            (u) => _TopUserCard(user: u, isDark: isDark),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Stat Card
// All amount-related fields here are RAW (unformatted) strings straight
// from the API. formatAmount() is only ever called at display time,
// right before a Text widget — never on a value that gets re-parsed
// or used in arithmetic afterwards.
// ─────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String netIncome;
  final String taxValue;
  final String deliveryFeeValue;
  final String packagingFeeValue;
  final String discountAmount;
  final String discountPercent;
  final String refundAmount;
  final String debtAmount;
  final String expenseAmount;
  final String purchaseAmount;
  final String totalPaymentAmount;
  final String total;
  final String sub;
  final bool dark;
  final bool isDark;
  final IconData icon;
  final bool fullWidth;

  const _StatCard({
    required this.label,
    required this.netIncome,
    required this.taxValue,
    required this.deliveryFeeValue,
    required this.packagingFeeValue,
    required this.discountAmount,
    required this.discountPercent,
    required this.sub,
    required this.dark,
    required this.icon,
    required this.refundAmount,
    required this.debtAmount,
    required this.expenseAmount,
    required this.purchaseAmount,
    required this.totalPaymentAmount,
    required this.total,
    this.isDark = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final otherExpenseTotal =
        (double.tryParse(refundAmount) ?? 0) +
        (double.tryParse(expenseAmount) ?? 0) +
        (double.tryParse(purchaseAmount) ?? 0);
    final netIncomeValue = double.tryParse(netIncome) ?? 0;
    final isNegative = netIncomeValue < 0;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: dark
            ? const LinearGradient(
                colors: [
                  Color.fromARGB(255, 46, 54, 75),
                  Color.fromARGB(255, 30, 36, 52),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: dark ? null : (isDark ? kSurfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: dark ? Colors.white70 : kTextSubLight,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(
                isNegative ? Icons.trending_down_rounded : icon,
                color: isNegative
                    ? kRed
                    : (dark ? Colors.white60 : kPrimary.withOpacity(0.5)),
                size: 15,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            formatAmount(double.tryParse(netIncome) ?? 0),
            style: TextStyle(
              color: isNegative
                  ? kRed
                  : (dark ? Colors.white : (isDark ? kTextDark : kTextLight)),
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),

          // tax / deliveryFee / packagingFee / discountAmount / discountPercent
          // intentionally left off the card — order-composition detail,
          // not income-health detail. Move to a "Sale detail" screen if needed.
          StatCardRow(
            label:
                "${IncomeScreenLocale.incomeDebtAmount.getString(context)} :",
            value: formatAmount(double.tryParse(debtAmount) ?? 0),
            dark: dark,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          StatCardRow(
            label:
                "${IncomeScreenLocale.incomeTotalPaymentAmount.getString(context)} :",
            value: formatAmount(double.tryParse(totalPaymentAmount) ?? 0),
            dark: dark,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          const Divider(),
          StatCardRow(
            label:
                "${IncomeScreenLocale.incomeTotalSales.getString(context)} :",
            labelColor: kGreen,
            valueColor: kGreenSecondary,
            value: formatAmount(double.tryParse(total) ?? 0),
            dark: dark,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          Text(
            IncomeScreenLocale.incomeOtherExpense.getString(context),
            style: TextStyle(
              color: (dark ? Colors.white : (isDark ? kTextDark : kTextLight)),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const Divider(),
          StatCardRow(
            label:
                "${IncomeScreenLocale.incomeRefundAmount.getString(context)} :",
            value: formatAmount(double.tryParse(refundAmount) ?? 0),
            dark: dark,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          StatCardRow(
            label:
                "${IncomeScreenLocale.incomeExpenseAmount.getString(context)} :",
            value: formatAmount(double.tryParse(expenseAmount) ?? 0),
            dark: dark,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          StatCardRow(
            label:
                "${IncomeScreenLocale.incomePurchaseAmount.getString(context)} :",
            value: formatAmount(double.tryParse(purchaseAmount) ?? 0),
            dark: dark,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 6),
          StatCardRow(
            label:
                "${IncomeScreenLocale.incomeTotalOtherExpense.getString(context)} :",
            labelColor: kRed,
            valueColor: kRed,
            value: formatAmount(otherExpenseTotal),
            dark: dark,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class StatCardRow extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final String value;
  final Color? valueColor;
  final bool dark;
  final bool isDark;
  const StatCardRow({
    super.key,
    required this.label,
    this.labelColor,
    this.valueColor,
    required this.value,
    required this.dark,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color:
                labelColor ??
                (dark ? Colors.white : (isDark ? kTextDark : kTextLight)),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            color:
                valueColor ??
                (dark ? Colors.white : (isDark ? kTextDark : kTextLight)),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Item Rank Card
// ─────────────────────────────────────────
class _ItemRankCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool dark;
  final bool isDark;
  final List<SaleItem> items;

  const _ItemRankCard({
    required this.title,
    required this.icon,
    required this.dark,
    required this.isDark,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : (isDark ? kTextDark : kTextLight);
    final fgSub = dark ? Colors.white54 : kTextSubLight;
    final badgeBg = dark
        ? Colors.white.withOpacity(0.15)
        : kPrimary.withOpacity(0.08);
    final badgeFg = dark ? Colors.white : kPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: dark
            ? const LinearGradient(
                colors: [kPrimary, kSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: dark ? null : (isDark ? kSurfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: dark
                ? kPrimary.withOpacity(0.3)
                : (isDark
                      ? kPrimary.withOpacity(0.1)
                      : Colors.black.withOpacity(0.06)),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: fg, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.take(120).toList().asMap().entries.map((e) {
            final rank = e.key + 1;
            final item = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        color: badgeFg,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(color: fg, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${item.totalQuantity}',
                    style: TextStyle(color: fgSub, fontSize: 11),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color textColor;

  const _SectionHeader({required this.title, required this.textColor});

  @override
  Widget build(BuildContext context) {
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
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Monthly Bar Chart
// ─────────────────────────────────────────
class _MonthlyBarChart extends StatelessWidget {
  final List<MonthlySale> monthlyData;
  final bool isDark;

  const _MonthlyBarChart({required this.monthlyData, required this.isDark});

  double get _maxY {
    double max = 0;
    for (var item in monthlyData) {
      final v = double.tryParse(item.total) ?? 0;
      if (v > max) max = v;
    }
    return max == 0 ? 100 : max * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    const months = {
      "1": "JAN",
      "2": "FEB",
      "3": "MAR",
      "4": "APR",
      "5": "MAY",
      "6": "JUN",
      "7": "JUL",
      "8": "AUG",
      "9": "SEP",
      "10": "OCT",
      "11": "NOV",
      "12": "DEC",
    };

    final monthColors = {
      "1": Colors.blue,
      "2": Colors.pink,
      "3": Colors.green,
      "4": Colors.orange,
      "5": Colors.purple,
      "6": Colors.teal,
      "7": Colors.red,
      "8": Colors.indigo,
      "9": Colors.amber,
      "10": Colors.cyan,
      "11": Colors.deepPurple,
      "12": Colors.brown,
    };

    final cardColor = isDark ? kSurfaceDark : Colors.white;
    final gridColor = isDark
        ? Colors.white.withOpacity(0.06)
        : const Color(0xFFF3F4F6);
    final labelColor = isDark ? kTextSubDark : const Color(0xFF9CA3AF);

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? kPrimary.withOpacity(0.1)
                : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: gridColor, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, _) {
                  if (value == 0) return const SizedBox();
                  final label = value >= 1000
                      ? '${(value / 1000).toStringAsFixed(0)}K'
                      : value.toStringAsFixed(0);
                  return Text(
                    label,
                    style: TextStyle(color: labelColor, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= monthlyData.length) {
                    return const SizedBox();
                  }
                  final monthName = months[monthlyData[index].month] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      monthName,
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1E1B4B),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final monthName = months[monthlyData[group.x].month] ?? '';
                return BarTooltipItem(
                  '$monthName\n',
                  const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: rod.toY.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: List.generate(monthlyData.length, (index) {
            final item = monthlyData[index];
            final total = double.tryParse(item.total) ?? 0;

            final color = monthColors[item.month] ?? kPrimary;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: total,
                  width: 28,
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Top User Card
// ─────────────────────────────────────────
class _TopUserCard extends StatelessWidget {
  final MonthlyTopSaleUser user;
  final bool isDark;

  const _TopUserCard({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final name = [
      user.saleFirstName,
      user.saleLastName,
    ].where((s) => s != null && s.isNotEmpty).join(' ');
    final displayName = name.isEmpty ? user.saleEmail : name;
    final initials = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? kSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? kPrimary.withOpacity(0.1)
                : Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimary, kSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    color: isDark ? kTextDark : kTextLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (user.phone != null)
                  Text(
                    user.phone!,
                    style: TextStyle(
                      color: isDark ? kTextDark : kTextLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 2),
                Text(
                  user.saleEmail,
                  style: TextStyle(
                    color: isDark ? kTextSubDark : kTextSubLight,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatAmount(double.tryParse(user.total) ?? 0),
                style: const TextStyle(
                  color: kPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                IncomeScreenLocale.incomeTotalSales.getString(context),
                style: TextStyle(
                  color: isDark ? kTextSubDark : kTextSubLight,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
