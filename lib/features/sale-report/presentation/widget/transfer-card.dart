import 'package:flutter/material.dart';
import 'package:pos/features/sale-report/data/model/sale-report.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/myanmar-safe-printer.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TransferCard extends StatelessWidget {
  const TransferCard({
    super.key,
    required this.transfer,
    required this.isDark,
    required this.canDelete,
    required this.onDelete,
  });

  final Transfer transfer;
  final bool isDark;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final isExternal = transfer.transferType == TransferType.external;

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
              gradient: const LinearGradient(
                colors: [kPrimary, kSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.arrowRightLeft,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // ── From → To + date + type ──────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        transfer.fromAccount.accountName,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: FontSizeConfig.body(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        LucideIcons.arrowRight,
                        size: 14,
                        color: subColor,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        transfer.toAccount.accountName,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: FontSizeConfig.body(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isExternal
                            ? kAmber.withOpacity(0.15)
                            : (isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isExternal ? "EXTERNAL" : "INTERNAL",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: isExternal ? kAmber : subColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy').format(transfer.date),
                      style: TextStyle(color: subColor, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(transfer.saleUser.email),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Amount + delete ──────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatAmount(transfer.amount),
                style: const TextStyle(
                  color: kPrimary,
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
