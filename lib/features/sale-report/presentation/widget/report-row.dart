// ─────────────────────────────────────────────
// 📊 Report Row
// ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/utils/app-theme.dart';

class ReportRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String amount;
  final bool isPositive;
  final bool highlight;
  final bool isDark;

  const ReportRow({
    super.key,
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

    // decimal ရှိရင် ပြမယ်၊ မရှိရင် (.0) ဖျောက်ပစ်မယ်
    final isWhole = number == number.roundToDouble();
    final pattern = isWhole ? '#,###' : '#,###.##';

    return NumberFormat(pattern).format(number);
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark ? kTextDark : const Color(0xFF6B7280);
    final amountColor = isDark
        ? kTextDark
        : (isPositive ? const Color(0xFF059669) : const Color(0xFF111827));

    final formatted = _formatAmount(amount);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                formatted,
                maxLines: 1,
                style: TextStyle(
                  fontSize: highlight ? 17 : 15,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
