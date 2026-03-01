// ─────────────────────────────────────────────
// 📊 Report Row
// ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ReportRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String amount;
  final bool isPositive;
  final bool highlight;
  final bool isDark;

  const ReportRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.isPositive,
    required this.isDark,
    this.highlight = false,
  });

  String _formatAmount(String raw) {
    final number = double.tryParse(raw);
    if (number == null) return raw;
    return NumberFormat('#,##0.00').format(number);
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark ? kTextDark : const Color(0xFF6B7280);
    final amountColor = isDark ? kTextDark : const Color(0xFF111827);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: highlight
          ? BoxDecoration(
              color: kPrimary.withOpacity(isDark ? 0.1 : 0.04),
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
              style: TextStyle(
                fontSize: 13,
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            _formatAmount(amount),
            style: TextStyle(
              fontSize: highlight ? 17 : 15,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
