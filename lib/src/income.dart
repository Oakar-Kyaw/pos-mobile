// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localization/flutter_localization.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:pos/api/income-dashboard.api.dart';
// import 'package:pos/component/app-bar.dart';
// import 'package:pos/localization/drawer-local.dart';
// import 'package:pos/models/dashboard-stats.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';

// class IncomePage extends ConsumerWidget {
//   const IncomePage({super.key});

//   String _formatNumber(String value) {
//     final num = double.tryParse(value) ?? 0;
//     if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
//     if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
//     return num.toStringAsFixed(0);
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final incomeDataAsync = ref.watch(incomeProvider);

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: CustomAppBar(
//         leading: IconButton(
//           onPressed: () => context.pop(),
//           icon: Icon(LucideIcons.arrowLeft),
//         ),
//         title: DrawerScreenLocale.drawerIncome.getString(context),
//       ),
//       body: incomeDataAsync.when(
//         data: (data) => _buildBody(context, data),
//         error: (e, _) => Center(
//           child: Text(
//             'Error: $e',
//             style: const TextStyle(color: Colors.black54),
//           ),
//         ),
//         loading: () =>
//             const Center(child: CircularProgressIndicator(color: Colors.black)),
//       ),
//     );
//   }

//   Widget _buildBody(BuildContext context, DashboardStats data) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'OVERVIEW',
//             style: TextStyle(
//               color: Color(0xFF999999),
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 2,
//             ),
//           ),
//           const SizedBox(height: 12),

//           Row(
//             children: [
//               Expanded(
//                 child: _StatCard(
//                   label: 'This Year',
//                   value: _formatNumber(data.yearlySale.total),
//                   sub:
//                       'Tax ${_formatNumber(data.yearlySale.tax)}  •  Fee ${_formatNumber(data.yearlySale.deliveryFee)}',
//                   dark: true,
//                   icon: Icons.trending_up_rounded,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _StatCard(
//                   label: 'This Month',
//                   value: _formatNumber(data.monthlySale.total),
//                   sub:
//                       'Tax ${_formatNumber(data.monthlySale.tax)}  •  Fee ${_formatNumber(data.monthlySale.deliveryFee)}',
//                   dark: false,
//                   icon: Icons.calendar_today_rounded,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           _StatCard(
//             label: 'Today',
//             value: _formatNumber(data.getTodaySale.total),
//             sub:
//                 'Tax ${_formatNumber(data.getTodaySale.tax)}  •  Fee ${_formatNumber(data.getTodaySale.deliveryFee)}',
//             dark: true,
//             icon: Icons.trending_up_rounded,
//           ),

//           const SizedBox(height: 20),

//           Row(
//             children: [
//               Expanded(
//                 child: _ItemRankCard(
//                   title: 'Top Seller',
//                   icon: Icons.local_fire_department_rounded,
//                   dark: true,
//                   items: data.mostSellingItem,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _ItemRankCard(
//                   title: 'Least Sold',
//                   icon: Icons.arrow_downward_rounded,
//                   dark: false,
//                   items: data.leastSellingItem,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 24),
//           const _SectionHeader(title: 'Monthly Revenue'),
//           const SizedBox(height: 14),
//           _MonthlyBarChart(monthlyData: data.getMonthByMonth),

//           const SizedBox(height: 24),
//           const _SectionHeader(title: 'Top Sales Staff'),
//           const SizedBox(height: 12),
//           ...data.getMonthlyTopSaleUser.map(
//             (u) => _TopUserCard(user: u, formatNumber: _formatNumber),
//           ),

//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────
// // Stat Card — alternates black / white
// // ─────────────────────────────────────────
// class _StatCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final String sub;
//   final bool dark;
//   final IconData icon;

//   const _StatCard({
//     required this.label,
//     required this.value,
//     required this.sub,
//     required this.dark,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bg = dark ? const Color.fromARGB(255, 41, 41, 41) : Colors.white;
//     final fg = dark ? Colors.white : Colors.black;
//     final fgSub = dark ? Colors.white54 : Colors.black38;

//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(dark ? 0.22 : 0.08),
//             blurRadius: 16,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: fgSub,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//               Icon(icon, color: fgSub, size: 15),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             value,
//             style: TextStyle(
//               color: fg,
//               fontSize: 28,
//               fontWeight: FontWeight.w800,
//               letterSpacing: -1,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(sub, style: TextStyle(color: fgSub, fontSize: 10)),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────
// // Item Rank Card
// // ─────────────────────────────────────────
// class _ItemRankCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final bool dark;
//   final List<SaleItem> items;

//   const _ItemRankCard({
//     required this.title,
//     required this.icon,
//     required this.dark,
//     required this.items,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bg = dark ? const Color.fromARGB(255, 43, 43, 43) : Colors.white;
//     final fg = dark ? Colors.white : Colors.black;
//     final fgSub = dark ? Colors.white38 : Colors.black38;
//     final badgeBg = dark ? Colors.white12 : Colors.black.withOpacity(0.07);

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: const Color.fromARGB(
//               255,
//               30,
//               29,
//               29,
//             ).withOpacity(dark ? 0.18 : 0.07),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: fg, size: 16),
//               const SizedBox(width: 6),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: fg,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 13,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ...items.take(120).toList().asMap().entries.map((e) {
//             final rank = e.key + 1;
//             final item = e.value;
//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 20,
//                     height: 20,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       color: badgeBg,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       '$rank',
//                       style: TextStyle(
//                         color: fg,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       item.name,
//                       style: TextStyle(color: fg, fontSize: 12),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   Text(
//                     '${item.totalQuantity}',
//                     style: TextStyle(color: fgSub, fontSize: 11),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────
// // Section Header
// // ─────────────────────────────────────────
// class _SectionHeader extends StatelessWidget {
//   final String title;
//   const _SectionHeader({required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       title,
//       style: const TextStyle(
//         color: Colors.black,
//         fontSize: 16,
//         fontWeight: FontWeight.w700,
//         letterSpacing: -0.3,
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────
// // Monthly Bar Chart
// // ─────────────────────────────────────────
// class _MonthlyBarChart extends StatelessWidget {
//   final List<MonthlySale> monthlyData;
//   const _MonthlyBarChart({required this.monthlyData});

//   double get _maxY {
//     double max = 0;
//     for (var item in monthlyData) {
//       final v = double.tryParse(item.total) ?? 0;
//       if (v > max) max = v;
//     }
//     return max * 1.2;
//   }

//   @override
//   Widget build(BuildContext context) {
//     const months = {
//       "1": "JAN",
//       "2": "FEB",
//       "3": "MAR",
//       "4": "APR",
//       "5": "MAY",
//       "6": "JUN",
//       "7": "JUL",
//       "8": "AUG",
//       "9": "SEP",
//       "10": "OCT",
//       "11": "NOV",
//       "12": "DEC",
//     };

//     return Container(
//       height: 240,
//       padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: const Color.fromARGB(255, 25, 25, 25).withOpacity(0.07),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: BarChart(
//         BarChartData(
//           alignment: BarChartAlignment.spaceAround,
//           maxY: _maxY,
//           gridData: FlGridData(
//             show: true,
//             drawVerticalLine: false,
//             getDrawingHorizontalLine: (_) => FlLine(
//               color: const Color.fromARGB(255, 53, 51, 51).withOpacity(0.06),
//               strokeWidth: 1,
//             ),
//           ),
//           borderData: FlBorderData(show: false),
//           titlesData: FlTitlesData(
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 45,
//                 getTitlesWidget: (value, _) {
//                   if (value == 0) return const SizedBox();
//                   final label = value >= 1000
//                       ? '${(value / 1000).toStringAsFixed(0)}K'
//                       : value.toStringAsFixed(0);
//                   return Text(
//                     label,
//                     style: const TextStyle(
//                       color: Color.fromARGB(255, 60, 60, 60),
//                       fontSize: 10,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (value, _) {
//                   final index = value.toInt();
//                   if (index < 0 || index >= monthlyData.length) {
//                     return const SizedBox();
//                   }
//                   final monthName = months[monthlyData[index].month] ?? '';
//                   return Padding(
//                     padding: const EdgeInsets.only(top: 6),
//                     child: Text(
//                       monthName,
//                       style: const TextStyle(
//                         color: Color(0xFF888888),
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             rightTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             topTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//           ),
//           barTouchData: BarTouchData(
//             touchTooltipData: BarTouchTooltipData(
//               getTooltipColor: (_) => Colors.grey.shade200, // grey background
//               getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                 final monthName = months[monthlyData[group.x].month] ?? '';
//                 final value = rod.toY.toStringAsFixed(2);
//                 return BarTooltipItem(
//                   '$monthName\n',
//                   const TextStyle(
//                     color: Colors.black54,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   children: [
//                     TextSpan(
//                       text: value,
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//           barGroups: List.generate(monthlyData.length, (index) {
//             final total = double.tryParse(monthlyData[index].total) ?? 0;
//             return BarChartGroupData(
//               x: index,
//               barRods: [
//                 BarChartRodData(
//                   toY: total,
//                   width: 28,
//                   borderRadius: BorderRadius.circular(6),
//                   color: const Color.fromARGB(255, 34, 34, 34),
//                 ),
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────
// // Top User Card
// // ─────────────────────────────────────────
// class _TopUserCard extends StatelessWidget {
//   final MonthlyTopSaleUser user;
//   final String Function(String) formatNumber;

//   const _TopUserCard({required this.user, required this.formatNumber});

//   @override
//   Widget build(BuildContext context) {
//     final name = [
//       user.saleFirstName,
//       user.saleLastName,
//     ].where((s) => s != null && s.isNotEmpty).join(' ');
//     final displayName = name.isEmpty ? user.saleEmail : name;
//     final initials = displayName.isNotEmpty
//         ? displayName[0].toUpperCase()
//         : '?';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.07),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: const Color.fromARGB(255, 40, 39, 39),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               initials,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 18,
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   displayName,
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   user.saleEmail,
//                   style: const TextStyle(
//                     color: Color(0xFF999999),
//                     fontSize: 11,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 formatNumber(user.total),
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.w800,
//                   fontSize: 16,
//                 ),
//               ),
//               const Text(
//                 'total sales',
//                 style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 10),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/income-dashboard.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/models/dashboard-stats.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// ─── Brand Colors ───────────────────────────
const _kPrimary = Color(0xFF6366F1); // indigo
const _kSecondary = Color(0xFF8B5CF6); // violet
const _kBg = Color(0xFFF5F6FA); // page background
const _kGreen = Color(0xFF10B981);
const _kAmber = Color(0xFFF59E0B);
const _kCardDark = Color(0xFF1E1B4B); // deep indigo dark card
const _kCardDarkSub = Color(0xFF6366F1); // lighter indigo for sub text on dark

class IncomePage extends ConsumerWidget {
  const IncomePage({super.key});

  String _formatNumber(String value) {
    final num = double.tryParse(value) ?? 0;
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeDataAsync = ref.watch(incomeProvider);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: DrawerScreenLocale.drawerIncome.getString(context),
      ),
      body: incomeDataAsync.when(
        data: (data) => _buildBody(context, data),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.black54),
          ),
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _kPrimary)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardStats data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OVERVIEW',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
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
                  label: 'This Year',
                  value: _formatNumber(data.yearlySale.total),
                  sub:
                      'Tax ${_formatNumber(data.yearlySale.tax)}  •  Fee ${_formatNumber(data.yearlySale.deliveryFee)}',
                  dark: true,
                  icon: Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'This Month',
                  value: _formatNumber(data.monthlySale.total),
                  sub:
                      'Tax ${_formatNumber(data.monthlySale.tax)}  •  Fee ${_formatNumber(data.monthlySale.deliveryFee)}',
                  dark: false,
                  icon: Icons.calendar_today_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _StatCard(
            label: 'Today',
            value: _formatNumber(data.getTodaySale.total),
            sub:
                'Tax ${_formatNumber(data.getTodaySale.tax)}  •  Fee ${_formatNumber(data.getTodaySale.deliveryFee)}',
            dark: true,
            icon: Icons.trending_up_rounded,
            fullWidth: true,
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _ItemRankCard(
                  title: 'Top Seller',
                  icon: Icons.local_fire_department_rounded,
                  dark: true,
                  items: data.mostSellingItem,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ItemRankCard(
                  title: 'Least Sold',
                  icon: Icons.arrow_downward_rounded,
                  dark: false,
                  items: data.leastSellingItem,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Monthly Revenue'),
          const SizedBox(height: 14),
          _MonthlyBarChart(monthlyData: data.getMonthByMonth),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Top Sales Staff'),
          const SizedBox(height: 12),
          ...data.getMonthlyTopSaleUser.map(
            (u) => _TopUserCard(user: u, formatNumber: _formatNumber),
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
  final IconData icon;
  final bool fullWidth;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.dark,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    // Dark card: deep indigo gradient. Light card: white with indigo accents.
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: dark
            ? const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: dark ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: dark
                ? _kPrimary.withOpacity(0.35)
                : Colors.black.withOpacity(0.06),
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
                  color: dark ? Colors.white70 : const Color(0xFF9CA3AF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(
                icon,
                color: dark ? Colors.white60 : _kPrimary.withOpacity(0.5),
                size: 15,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: dark ? Colors.white : const Color(0xFF111827),
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: TextStyle(
              color: dark ? Colors.white54 : const Color(0xFF9CA3AF),
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
  final List<SaleItem> items;

  const _ItemRankCard({
    required this.title,
    required this.icon,
    required this.dark,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bg = dark
        ? const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;
    final fg = dark ? Colors.white : const Color(0xFF111827);
    final fgSub = dark ? Colors.white54 : const Color(0xFF9CA3AF);
    final badgeBg = dark
        ? Colors.white.withOpacity(0.15)
        : _kPrimary.withOpacity(0.08);
    final badgeFg = dark ? Colors.white : _kPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: bg,
        color: dark ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: dark
                ? _kPrimary.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
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
                  fontSize: 13,
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
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kPrimary, _kSecondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
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
  const _MonthlyBarChart({required this.monthlyData});

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

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
                FlLine(color: const Color(0xFFF3F4F6), strokeWidth: 1),
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
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 10,
                    ),
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
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
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
                final value = rod.toY.toStringAsFixed(2);
                return BarTooltipItem(
                  '$monthName\n',
                  const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: value,
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
                    colors: [_kPrimary, _kSecondary],
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

  const _TopUserCard({required this.user, required this.formatNumber});

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with gradient
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kPrimary, _kSecondary],
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
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.saleEmail,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
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
                  color: _kPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const Text(
                'total sales',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
