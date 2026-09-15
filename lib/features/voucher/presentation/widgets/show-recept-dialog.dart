// features/voucher/presentation/widgets/show-receipt-dialog.dart
import 'package:flutter/material.dart';
import 'package:pos/features/voucher/data/model/voucher-detail.dart';
import 'package:pos/features/voucher/presentation/pages/receipt-voucher.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Future<void> showReceiptVoucherDialog(
  BuildContext context,
  VoucherDetailModel voucher,
) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return ShadDialog(
        child: SingleChildScrollView(
          child: Center(child: ReceiptVoucherWidget(voucher: voucher)),
        ),
      );
    },
  );
}
