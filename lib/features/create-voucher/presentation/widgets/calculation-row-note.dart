import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Widget rowNote(WidgetRef ref, String label, Color textColor) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      ),
      const SizedBox(width: 50),
      Expanded(
        child: ShadInputFormField(
          decoration: ShadDecoration(secondaryFocusedBorder: ShadBorder.none),
          onChanged: (value) {
            ref.read(voucherDetailProvider.notifier).updateVoucher(note: value);
          },
        ),
      ),
    ],
  );
}
