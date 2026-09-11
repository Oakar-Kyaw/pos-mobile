import 'package:flutter/material.dart';
import 'package:pos/features/sale-report/data/model/sale-report.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/myanmar-safe-printer.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SaleReportEntryCard extends StatelessWidget {
  const SaleReportEntryCard({
    super.key,
    required this.entry,
    required this.isDark,
    required this.canDelete,
    required this.onDelete,
  });

  final SaleReportEntry entry;
  final bool isDark;
  final bool canDelete;
  final VoidCallback onDelete;

  Color _typeColor(TransactionType type) {
    switch (type) {
      case TransactionType.openingBalance:
        return kGreen;
      case TransactionType.closingBalance:
        return kAmber;
      case TransactionType.sale:
        return kPrimary;
      case TransactionType.refund:
      case TransactionType.expense:
        return kRed;
      case TransactionType.unknown:
        return Colors.grey;
    }
  }

  IconData _typeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.openingBalance:
        return LucideIcons.walletMinimal;
      case TransactionType.closingBalance:
        return LucideIcons.lockKeyhole;
      case TransactionType.sale:
        return LucideIcons.trendingUp;
      case TransactionType.refund:
        return LucideIcons.undo2;
      case TransactionType.expense:
        return LucideIcons.receipt;
      case TransactionType.unknown:
        return LucideIcons.circleHelp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final typeColor = _typeColor(entry.type);
    final isNegative =
        entry.type == TransactionType.refund ||
        entry.type == TransactionType.expense;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
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
          // ── Icon ─────────────────────────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_typeIcon(entry.type), color: typeColor, size: 18),
          ),
          const SizedBox(width: 12),

          // ── Type + description + date ────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        entry.type.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('dd MMM yyyy').format(entry.date),
                  style: TextStyle(color: subColor, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.saleUser.email,
                  style: TextStyle(color: subColor, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Amount + delete ──────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isNegative ? '-' : ''}${formatAmount(entry.amount)}",
                style: TextStyle(
                  color: isNegative ? kRed : kGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (canDelete)
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(LucideIcons.trash2, size: 16, color: kRed),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
