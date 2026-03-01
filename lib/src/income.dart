import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/income-dashboard.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/income-local.dart';
import 'package:pos/models/dashboard-stats.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/date-ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class IncomePage extends ConsumerStatefulWidget {
  const IncomePage({super.key});

  @override
  ConsumerState<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends ConsumerState<IncomePage> {
  DateTime selectedDate = DateTime.now();

  String _formatNumber(String value) {
    final num = double.tryParse(value) ?? 0;
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toStringAsFixed(0);
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

      ref.read(incomeProvider.notifier).getIncomesByCompany(date: selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final incomeDataAsync = ref.watch(incomeProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final formattedDate = DateFormat('EEE, dd MMM yyyy').format(selectedDate);

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

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: IncomeScreenLocale.incomeThisYear.getString(context),
                  value: _formatNumber(data.yearlySale.total),
                  sub:
                      '${IncomeScreenLocale.incomeTax.getString(context)} ${_formatNumber(data.yearlySale.tax)}  •  ${IncomeScreenLocale.incomeFee.getString(context)} ${_formatNumber(data.yearlySale.deliveryFee)}',
                  dark: true,
                  icon: Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: IncomeScreenLocale.incomeThisMonth.getString(context),
                  value: _formatNumber(data.monthlySale.total),
                  sub:
                      '${IncomeScreenLocale.incomeTax.getString(context)} ${_formatNumber(data.monthlySale.tax)}  •  ${IncomeScreenLocale.incomeFee.getString(context)} ${_formatNumber(data.monthlySale.deliveryFee)}',
                  dark: false,
                  isDark: isDark,
                  icon: Icons.calendar_today_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _StatCard(
            label: IncomeScreenLocale.incomeToday.getString(context),
            value: _formatNumber(data.getTodaySale.total),
            sub:
                '${IncomeScreenLocale.incomeTax.getString(context)} ${_formatNumber(data.getTodaySale.tax)}  •  ${IncomeScreenLocale.incomeFee.getString(context)} ${_formatNumber(data.getTodaySale.deliveryFee)}',
            dark: true,
            icon: Icons.trending_up_rounded,
            fullWidth: true,
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
            title: IncomeScreenLocale.incomeMonthlyRevenue.getString(context),
            textColor: textColor,
          ),
          const SizedBox(height: 14),
          _MonthlyBarChart(monthlyData: data.getMonthByMonth, isDark: isDark),

          const SizedBox(height: 24),
          _SectionHeader(
            title: IncomeScreenLocale.incomeTopSalesStaff.getString(context),
            textColor: textColor,
          ),
          const SizedBox(height: 12),
          ...data.getMonthlyTopSaleUser.map(
            (u) => _TopUserCard(
              user: u,
              formatNumber: _formatNumber,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Stat Card
// ─────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final bool dark;
  final bool isDark;
  final IconData icon;
  final bool fullWidth;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.dark,
    required this.icon,
    this.isDark = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
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
                ? kPrimary.withOpacity(0.35)
                : (isDark
                      ? kPrimary.withOpacity(0.1)
                      : Colors.black.withOpacity(0.06)),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(
                icon,
                color: dark ? Colors.white60 : kPrimary.withOpacity(0.5),
                size: 15,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: dark ? Colors.white : (isDark ? kTextDark : kTextLight),
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: TextStyle(
              color: dark ? Colors.white54 : kTextSubLight,
              fontSize: 10,
            ),
          ),
        ],
      ),
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
    return max * 1.2;
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
                  if (index < 0 || index >= monthlyData.length)
                    return const SizedBox();
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
            final total = double.tryParse(monthlyData[index].total) ?? 0;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: total,
                  width: 28,
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [kPrimary, kSecondary],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
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
  final String Function(String) formatNumber;
  final bool isDark;

  const _TopUserCard({
    required this.user,
    required this.formatNumber,
    required this.isDark,
  });

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
                formatNumber(user.total),
                style: const TextStyle(
                  color: kPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                'total sales',
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
