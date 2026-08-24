import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Widget rowDeliveryFee(WidgetRef ref, String label, Color textColor) {
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
          initialValue: ref
              .watch(voucherDetailProvider)!
              .deliveryFee
              .toString(),
          textAlign: TextAlign.right,
          decoration: ShadDecoration(secondaryFocusedBorder: ShadBorder.none),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            final val = double.tryParse(value) ?? 0.0;
            ref
                .read(voucherDetailProvider.notifier)
                .updateVoucher(deliveryFee: val);
            ref.read(voucherDetailProvider.notifier).calculate();
          },
        ),
      ),
    ],
  );
}
