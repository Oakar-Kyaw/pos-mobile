import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/component/accent-bar.dart';
import 'package:pos/component/voucher-body.dart';
import 'package:pos/component/voucher-header.dart';
import 'package:pos/localization/payment-data-local.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/badge.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VoucherComponent extends StatelessWidget {
  VoucherComponent({
    super.key,
    required this.textColor,
    required this.subColor,
    required this.voucher,
    required this.pagingController,
  });

  final Color textColor;
  final Color subColor;
  final VoucherDetailModel voucher;
  PagingController<int, VoucherDetailModel> pagingController;

  @override
  Widget build(BuildContext context) {
    final bool hasDebt = voucher.existDebt ?? false;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccentBar(hasDebt: hasDebt),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderSection(
                    voucher: voucher,
                    textColor: textColor,
                    subColor: subColor,
                    hasDebt: hasDebt,
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  AmountSection(
                    voucher: voucher,
                    hasDebt: hasDebt,
                    pagingController: pagingController,
                    showButton: voucher.existDebt ?? false,
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Text(PaymentScreenLocale.paymentTitle.getString(context)),
                  if (voucher.payments.isNotEmpty)
                    ...voucher.payments.map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Text(e.paymentData!.accountName),
                            Spacer(),
                            BadgeWidget(
                              icon: Icons.credit_card,
                              label: e.amount.toString(),
                              color: kGreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
