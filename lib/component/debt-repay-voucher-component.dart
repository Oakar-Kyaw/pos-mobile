import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/component/accent-bar.dart';
import 'package:pos/component/delete-icon.dart';
import 'package:pos/component/voucher-body.dart';
import 'package:pos/component/voucher-header.dart';
import 'package:pos/models/voucher-detail.dart';

class DebtAndRepayVoucherListComponent extends StatelessWidget {
  DebtAndRepayVoucherListComponent({
    super.key,
    required this.textColor,
    required this.subColor,
    required this.voucher,
    required this.pagingController,
    this.onDelete,
  });

  final Color textColor;
  final Color subColor;
  final VoucherDetailModel voucher;
  PagingController<int, VoucherDetailModel> pagingController;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final bool hasDebt = voucher.existDebt ?? false;
    final theme = Theme.of(context);

    return Stack(
      children: [
        Container(
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
                        showButton: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (onDelete != null) DeleteIcon(onDelete: onDelete),
      ],
    );
  }
}
