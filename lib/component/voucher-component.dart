import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/component/voucher-body.dart';
import 'package:pos/component/voucher-header.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';

class VoucherListComponent extends StatelessWidget {
  VoucherListComponent({
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
          _AccentBar(hasDebt: hasDebt),
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

////////////////////////////////////////////////////////////////
/// Accent Bar
////////////////////////////////////////////////////////////////

class _AccentBar extends StatelessWidget {
  const _AccentBar({required this.hasDebt});

  final bool hasDebt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: hasDebt
              ? [Colors.red, Colors.red.withOpacity(0.4)]
              : [kPrimary, kPrimary.withOpacity(0.4)],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// Dialog Amount Row
////////////////////////////////////////////////////////////////
