import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/component/delete-icon.dart';
import 'package:pos/localization/debt-local.dart';
import 'package:pos/localization/repay-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/repayment.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:pos/utils/payment-icon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RepaymentCard extends StatelessWidget {
  const RepaymentCard({
    super.key,
    required this.repayment,
    required this.textColor,
    required this.subColor,
    this.onDelete,
  });

  final Repay repayment;
  final Color textColor;
  final Color subColor;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent bar
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [kGreen, kGreen.withOpacity(0.4)],
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Header Row ──
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Voucher code + date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kPrimary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        RepayLocaleScreen.repay.getString(
                                          context,
                                        ),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: kPrimary,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      repayment.voucher.voucherCode ?? '—',
                                      style: TextStyle(
                                        fontSize: FontSizeConfig.title(context),
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 11,
                                          color: subColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat(
                                            'dd MMM yyyy E',
                                          ).format(repayment.createdAt),
                                          style: TextStyle(
                                            fontSize: FontSizeConfig.body(
                                              context,
                                            ),
                                            color: subColor,
                                          ),
                                        ),
                                        Spacer(),
                                        // Repaid amount — prominent
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              RepayLocaleScreen.repaid
                                                  .getString(context),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: subColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              formatAmount(repayment.amount),
                                              style: TextStyle(
                                                fontSize:
                                                    FontSizeConfig.title(
                                                      context,
                                                    ) +
                                                    2,
                                                fontWeight: FontWeight.w800,
                                                color: kGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Divider
                          Divider(),

                          const SizedBox(height: 12),

                          // ── Footer Row ──
                          Row(
                            children: [
                              // Payment method chip
                              Expanded(
                                child: _InfoChip(
                                  icon: paymentIcon(
                                    repayment.paymentData.accountName,
                                  ),
                                  label: repayment.paymentData.accountName,
                                  sub: repayment.paymentData.accountType,
                                  color: kPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Voucher total chip
                              Expanded(
                                child: _InfoChip(
                                  icon: Icons.receipt_long_rounded,
                                  label: formatAmount(repayment.voucher.total),
                                  sub: VoucherScreenLocale.total.getString(
                                    context,
                                  ),
                                  color: Colors.orange.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Remaining chip
                              Expanded(
                                child: _InfoChip(
                                  icon: Icons.account_balance_wallet_rounded,
                                  label: formatAmount(
                                    repayment.voucher.remainingPaymentAmount,
                                  ),
                                  sub: DebtLocaleScreenLocale.debtRemaining
                                      .getString(context),
                                  color: (repayment.voucher.existDebt ?? false)
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),

                          // Account number (if exists)
                          if (repayment.paymentData.accountNumber != null) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.tag_rounded,
                                  size: 12,
                                  color: subColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  repayment.paymentData.accountNumber!,
                                  style: TextStyle(
                                    fontSize: FontSizeConfig.body(context),
                                    color: subColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onDelete != null) DeleteIcon(onDelete: onDelete),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////
/// Info Chip
////////////////////////////////////////////////////////////////

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11, color: color.withOpacity(0.8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: FontSizeConfig.body(context),
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
