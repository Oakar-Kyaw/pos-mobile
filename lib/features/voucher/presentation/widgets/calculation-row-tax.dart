import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Widget rowTax(WidgetRef ref, String label, Color textColor) {
  // 1. Read state safely without bang operator (!)
  final voucher = ref.watch(voucherDetailProvider);
  final taxValue = voucher?.tax.toString() ?? '0';

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      ),
      SizedBox(
        width: 80,
        child: ShadInputFormField(
          keyboardType: TextInputType.number,
          initialValue: taxValue, // 2. Safe initial value
          textAlign: TextAlign.right,
          decoration: const ShadDecoration(
            secondaryFocusedBorder: ShadBorder.none,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            final val = double.tryParse(value) ?? 0.0;
            ref.read(voucherDetailProvider.notifier).updateVoucher(tax: val);
            ref.read(voucherDetailProvider.notifier).calculate();
          },
        ),
      ),
    ],
  );
}
