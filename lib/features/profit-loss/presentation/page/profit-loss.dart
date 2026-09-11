import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/features/profit-loss/data/model/profit-loss.dart';
import 'package:pos/features/profit-loss/presentation/provider/profit-loss.provider.dart';
import 'package:pos/localization/profit-loss-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/date-ui.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProfitAndLossPage extends ConsumerStatefulWidget {
  const ProfitAndLossPage({super.key});

  @override
  ConsumerState<ProfitAndLossPage> createState() => _ProfitAndLossPageState();
}

class _ProfitAndLossPageState extends ConsumerState<ProfitAndLossPage> {
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

      ref
          .read(profitAndLossProvider.notifier)
          .getProfitAndLoss(date: selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(profitAndLossProvider);
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
        title: ProfitAndLossScreenLocale.profitAndLoss.getString(context),
      ),
      body: dataAsync.when(
        data: (data) => _buildBody(context, formattedDate, data, isDark),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '${ProfitAndLossScreenLocale.profitAndLossError.getString(context)}: $e',
              style: TextStyle(color: isDark ? kTextSubDark : Colors.black54),
              textAlign: TextAlign.center,
            ),
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
    ProfitAndLoss data,
    bool isDark,
  ) {
    final textColor = isDark ? kTextDark : kTextLight;

    return RefreshIndicator(
      color: kPrimary,
      onRefresh: () async {
        await ref
            .read(profitAndLossProvider.notifier)
            .getProfitAndLoss(date: selectedDate);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateSelectorCard(
              formattedDate: formattedDate,
              onTap: _pickDate,
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            _SectionHeader(
              title: ProfitAndLossScreenLocale.profitAndLossOverview.getString(
                context,
              ),
              textColor: textColor,
            ),

            const SizedBox(height: 14),

            _ProfitSummaryCard(
              title: ProfitAndLossScreenLocale.profitAndLossToday.getString(
                context,
              ),
              data: data.todayProfitAndLoss,
              dark: true,
              isDark: isDark,
              icon: Icons.today_rounded,
            ),

            const SizedBox(height: 12),

            _ProfitSummaryCard(
              title: ProfitAndLossScreenLocale.profitAndLossThisMonth.getString(
                context,
              ),
              data: data.monthlyProfitAndLoss,
              dark: false,
              isDark: isDark,
              icon: Icons.calendar_month_rounded,
            ),

            const SizedBox(height: 12),

            _ProfitSummaryCard(
              title: ProfitAndLossScreenLocale.profitAndLossThisYear.getString(
                context,
              ),
              data: data.yearlyProfitAndLoss,
              dark: true,
              isDark: isDark,
              icon: Icons.trending_up_rounded,
            ),

            const SizedBox(height: 28),

            _SectionHeader(
              title:
                  '${ProfitAndLossScreenLocale.profitAndLossToday.getString(context)} '
                  '${ProfitAndLossScreenLocale.profitAndLossItemProfitAndLoss.getString(context)}',
              textColor: textColor,
            ),

            const SizedBox(height: 14),

            _ItemProfitList(items: data.todayItemProfitAndLoss, isDark: isDark),

            const SizedBox(height: 28),

            _SectionHeader(
              title:
                  '${ProfitAndLossScreenLocale.profitAndLossThisMonth.getString(context)} '
                  '${ProfitAndLossScreenLocale.profitAndLossItemProfitAndLoss.getString(context)}',
              textColor: textColor,
            ),

            const SizedBox(height: 14),

            _ItemProfitList(
              items: data.monthlyItemProfitAndLoss,
              isDark: isDark,
            ),

            const SizedBox(height: 28),

            _SectionHeader(
              title:
                  '${ProfitAndLossScreenLocale.profitAndLossThisYear.getString(context)} '
                  '${ProfitAndLossScreenLocale.profitAndLossItemProfitAndLoss.getString(context)}',
              textColor: textColor,
            ),

            const SizedBox(height: 14),

            _ItemProfitList(
              items: data.yearlyItemProfitAndLoss,
              isDark: isDark,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
// DATE SELECTOR
// ═════════════════════════════════════════════════════

class _DateSelectorCard extends StatelessWidget {
  final String formattedDate;
  final VoidCallback onTap;
  final bool isDark;

  const _DateSelectorCard({
    required this.formattedDate,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? kSurfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? kPrimary.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kPrimary, kSecondary]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ProfitAndLossScreenLocale.profitAndLossDate.getString(
                      context,
                    ),
                    style: TextStyle(
                      color: isDark ? kTextSubDark : kTextSubLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: isDark ? kTextDark : kTextLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? kTextSubDark : kTextSubLight,
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
// PROFIT SUMMARY CARD
// ═════════════════════════════════════════════════════

class _ProfitSummaryCard extends StatelessWidget {
  final String title;
  final ProfitAndLossSummary data;
  final bool dark;
  final bool isDark;
  final IconData icon;

  const _ProfitSummaryCard({
    required this.title,
    required this.data,
    required this.dark,
    required this.isDark,
    required this.icon,
  });

  double _value(String value) {
    return double.tryParse(value) ?? 0;
  }

  // Percent fields come back from the backend as raw strings with many
  // decimal places (e.g. "98.762204190605320237"). Parse then clamp to
  // 2 decimals for display — never show the raw string.
  String _percent(dynamic value) {
    final parsed = double.tryParse(value.toString()) ?? 0;

    // Whole number → no decimals ("45" not "45.00")
    // Has a fractional part → 2 decimals ("98.76")
    if (parsed == parsed.truncateToDouble()) {
      return parsed.toStringAsFixed(0);
    }
    return parsed.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final netProfit = _value(data.netProfit.toString());
    final grossProfit = _value(data.grossProfit.toString());
    final netSales = _value(data.netSales.toString());

    final isProfitNegative = netProfit < 0;
    final isGrossProfitNegative = grossProfit < 0;

    final foreground = dark ? Colors.white : (isDark ? kTextDark : kTextLight);

    final foregroundSub = dark
        ? Colors.white54
        : (isDark ? kTextSubDark : kTextSubLight);

    return Container(
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: dark
                ? kPrimary.withOpacity(0.12)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                title,
                style: TextStyle(
                  color: foregroundSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(
                isProfitNegative ? Icons.trending_down_rounded : icon,
                size: 16,
                color: isProfitNegative
                    ? kRed
                    : (dark ? Colors.white60 : kPrimary.withOpacity(0.6)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            ProfitAndLossScreenLocale.profitAndLossNetProfit.getString(context),
            style: TextStyle(color: foregroundSub, fontSize: 10),
          ),

          const SizedBox(height: 3),

          Text(
            formatAmount(netProfit),
            style: TextStyle(
              color: isProfitNegative ? kRed : (dark ? Colors.white : kGreen),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _MarginBadge(
                label: ProfitAndLossScreenLocale.profitAndLossGrossMargin
                    .getString(context),
                value: '${_percent(data.grossMarginPercent)}%',
                negative: isGrossProfitNegative,
                dark: dark,
              ),
              const SizedBox(width: 8),
              _MarginBadge(
                label: ProfitAndLossScreenLocale.profitAndLossNetMargin
                    .getString(context),
                value: '${_percent(data.netMarginPercent)}%',
                negative: isProfitNegative,
                dark: dark,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          _ProfitRow(
            label: ProfitAndLossScreenLocale.profitAndLossGrossRevenue
                .getString(context),
            value: formatAmount(_value(data.grossRevenue.toString())),
            dark: dark,
            isDark: isDark,
          ),

          const SizedBox(height: 7),

          _ProfitRow(
            label: ProfitAndLossScreenLocale.profitAndLossRefundRevenue
                .getString(context),
            value: formatAmount(_value(data.refundRevenue.toString())),
            dark: dark,
            isDark: isDark,
          ),

          const SizedBox(height: 7),

          _ProfitRow(
            label: ProfitAndLossScreenLocale.profitAndLossNetSales.getString(
              context,
            ),
            value: formatAmount(netSales),
            valueColor: kGreen,
            dark: dark,
            isDark: isDark,
          ),

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          _ProfitRow(
            label: ProfitAndLossScreenLocale.profitAndLossCogs.getString(
              context,
            ),
            value: formatAmount(_value(data.cogs.toString())),
            dark: dark,
            isDark: isDark,
          ),

          const SizedBox(height: 7),

          _ProfitRow(
            label: ProfitAndLossScreenLocale.profitAndLossRefundCogs.getString(
              context,
            ),
            value: formatAmount(_value(data.refundCogs.toString())),
            dark: dark,
            isDark: isDark,
          ),

          const SizedBox(height: 7),

          _ProfitRow(
            label: ProfitAndLossScreenLocale.profitAndLossNetCogs.getString(
              context,
            ),
            value: formatAmount(_value(data.netCogs.toString())),
            dark: dark,
            isDark: isDark,
          ),

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          _ProfitRow(
            label: ProfitAndLossScreenLocale.profitAndLossGrossProfit.getString(
              context,
            ),
            value: formatAmount(grossProfit),
            labelColor: isGrossProfitNegative ? kRed : kGreen,
            valueColor: isGrossProfitNegative ? kRed : kGreen,
            bold: true,
            dark: dark,
            isDark: isDark,
          ),

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          Text(
            ProfitAndLossScreenLocale.profitAndLossExpenses.getString(context),
            style: TextStyle(
              color: foreground,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 9),

          _ProfitRow(
            label: ProfitAndLossScreenLocale.profitAndLossOperatingExpense
                .getString(context),
            value: formatAmount(_value(data.operatingExpense.toString())),
            dark: dark,
            isDark: isDark,
          ),

          const SizedBox(height: 7),

          _ProfitRow(
            label: ProfitAndLossScreenLocale.profitAndLossWastage.getString(
              context,
            ),
            value: formatAmount(_value(data.wastageAmount.toString())),
            dark: dark,
            isDark: isDark,
          ),

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          _ProfitRow(
            label: ProfitAndLossScreenLocale.profitAndLossNetProfit
                .getString(context)
                .toUpperCase(),
            value: formatAmount(netProfit),
            labelColor: isProfitNegative ? kRed : kGreen,
            valueColor: isProfitNegative ? kRed : kGreen,
            bold: true,
            dark: dark,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
// MARGIN BADGE
// ═════════════════════════════════════════════════════

class _MarginBadge extends StatelessWidget {
  final String label;
  final String value;
  final bool negative;
  final bool dark;

  const _MarginBadge({
    required this.label,
    required this.value,
    required this.negative,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: negative
              ? kRed.withOpacity(0.12)
              : (dark
                    ? Colors.white.withOpacity(0.08)
                    : kPrimary.withOpacity(0.08)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: dark ? Colors.white54 : kTextSubLight,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: negative ? kRed : (dark ? Colors.white : kPrimary),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
// PROFIT ROW
// ═════════════════════════════════════════════════════

class _ProfitRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;
  final bool bold;
  final bool dark;
  final bool isDark;

  const _ProfitRow({
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
    this.bold = false,
    required this.dark,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = dark
        ? Colors.white
        : (isDark ? kTextDark : kTextLight);

    final defaultSubColor = dark
        ? Colors.white70
        : (isDark ? kTextDark : kTextLight);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: labelColor ?? defaultSubColor,
              fontSize: 10,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? defaultColor,
            fontSize: 10,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════
// ITEM PROFIT LIST
// ═════════════════════════════════════════════════════

class _ItemProfitList extends StatelessWidget {
  final List<ItemProfitAndLoss> items;
  final bool isDark;

  const _ItemProfitList({required this.items, required this.isDark});

  double _value(String value) {
    return double.tryParse(value) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? kSurfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 30,
              color: isDark ? kTextSubDark : kTextSubLight,
            ),
            const SizedBox(height: 8),
            Text(
              ProfitAndLossScreenLocale.profitAndLossNoData.getString(context),
              style: TextStyle(
                color: isDark ? kTextSubDark : kTextSubLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? kSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? kPrimary.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ...items.take(50).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            final profit = _value(item.netProfit.toString());
            final margin = _value(item.netMarginPercent.toString());

            final isNegative = profit < 0;

            return Column(
              children: [
                _ItemProfitCard(
                  rank: index + 1,
                  item: item,
                  profit: profit,
                  margin: margin,
                  isNegative: isNegative,
                  isDark: isDark,
                ),
                if (index < items.length - 1 && index < 49)
                  Divider(
                    height: 1,
                    indent: 70,
                    endIndent: 16,
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.05),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
// ITEM PROFIT CARD
// ═════════════════════════════════════════════════════

class _ItemProfitCard extends StatelessWidget {
  final int rank;
  final ItemProfitAndLoss item;
  final double profit;
  final double margin;
  final bool isNegative;
  final bool isDark;

  const _ItemProfitCard({
    required this.rank,
    required this.item,
    required this.profit,
    required this.margin,
    required this.isNegative,
    required this.isDark,
  });

  double _value(String value) {
    return double.tryParse(value) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final foreground = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.photoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.photoUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      width: 65,
                      height: 70,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 20,
                      ),
                    ),
                  )
                : _ImagePlaceholder(isDark: isDark),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : kPrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: isDark ? kTextDark : kPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  '${ProfitAndLossScreenLocale.profitAndLossQuantity.getString(context)} ${item.soldQty}  •  '
                  '${ProfitAndLossScreenLocale.profitAndLossNetSales.getString(context)} ${formatAmount(_value(item.netSales.toString()))}',
                  style: TextStyle(
                    color: subColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '${ProfitAndLossScreenLocale.profitAndLossCogs.getString(context)} ${formatAmount(_value(item.netCogs.toString()))}',
                  style: TextStyle(color: subColor, fontSize: 9),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatAmount(profit),
                style: TextStyle(
                  color: isNegative ? kRed : kGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 3),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isNegative
                      ? kRed.withOpacity(0.1)
                      : kGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  // margin already comes in as a parsed double from
                  // _ItemProfitList, so this stays as-is (already 2 dp).
                  '${margin.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isNegative ? kRed : kGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                ProfitAndLossScreenLocale.profitAndLossNetProfit.getString(
                  context,
                ),
                style: TextStyle(color: subColor, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
// IMAGE PLACEHOLDER
// ═════════════════════════════════════════════════════

class _ImagePlaceholder extends StatelessWidget {
  final bool isDark;

  const _ImagePlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
      child: Icon(
        Icons.inventory_2_outlined,
        size: 20,
        color: isDark ? kTextSubDark : kTextSubLight,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
// SECTION HEADER
// ═════════════════════════════════════════════════════

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
