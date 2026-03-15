import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/badge.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    required this.voucher,
    required this.textColor,
    required this.subColor,
    required this.hasDebt,
  });

  final VoucherDetailModel voucher;
  final Color textColor;
  final Color subColor;
  final bool hasDebt;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BadgeWidget(
                    label: VoucherScreenLocale.voucher.getString(context),
                    color: kPrimary,
                    icon: LucideIcons.ticket,
                  ),
                  if (hasDebt) ...[
                    const SizedBox(width: 6),
                    BadgeWidget(
                      label: VoucherScreenLocale.hasDebt.getString(context),
                      color: Colors.red,
                      icon: LucideIcons.wallet,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              VoucherCardDescription(
                voucher: voucher,
                textColor: textColor,
                subColor: subColor,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }
}

class VoucherCardDescription extends StatelessWidget {
  const VoucherCardDescription({
    super.key,
    required this.voucher,
    required this.textColor,
    required this.subColor,
  });

  final VoucherDetailModel voucher;
  final Color textColor;
  final Color subColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              voucher.voucherCode ?? '—',
              style: TextStyle(
                fontSize: FontSizeConfig.title(context),
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 12, color: subColor),
                const SizedBox(width: 4),
                Text(
                  DateFormat(
                    'dd MMM yyyy EEEE',
                  ).format(voucher.createdAt ?? DateTime.now()),
                  style: TextStyle(
                    fontSize: FontSizeConfig.body(context),
                    color: subColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        _TotalAmount(voucher: voucher),
      ],
    );
  }
}

class _TotalAmount extends StatelessWidget {
  const _TotalAmount({required this.voucher});

  final VoucherDetailModel voucher;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          VoucherScreenLocale.total.getString(context),
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          formatAmount(voucher.total),
          style: TextStyle(
            fontSize: FontSizeConfig.title(context) + 2,
            fontWeight: FontWeight.w800,
            color: kPrimary,
          ),
        ),
      ],
    );
  }
}
