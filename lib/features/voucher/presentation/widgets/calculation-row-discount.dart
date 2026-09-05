import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Widget rowDiscount(
  BuildContext context,
  WidgetRef ref,
  String label,
  Color textColor, {
  addDiscount,
  bool isDiscountByPercent = true,
}) {
  String initialValue(bool isDiscountByPercent) {
    final voucher = ref.read(voucherDetailProvider)!;
    return isDiscountByPercent
        ? voucher.discountPercent.toString()
        : voucher.discountAmount.toString();
  }

  void onChangedSelect(bool isPercent) {
    addDiscount(isPercent);
    ref
        .read(voucherDetailProvider.notifier)
        .updateVoucher(discountAmount: 0, discountPercent: 0);
    ref.read(voucherDetailProvider.notifier).calculate();
  }

  void onChangedInput(value) {
    final val = double.tryParse(value) ?? 0.0;
    if (isDiscountByPercent) {
      ref
          .read(voucherDetailProvider.notifier)
          .updateVoucher(discountPercent: val);
    } else {
      ref
          .read(voucherDetailProvider.notifier)
          .updateVoucher(discountAmount: val);
    }
    ref.read(voucherDetailProvider.notifier).calculate();
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
            ),
            SizedBox(width: 5),
            SizedBox(
              width: 100,
              child: ShadSelect<String>(
                key: ValueKey(
                  isDiscountByPercent,
                ), // ★ forces dropdown to re-show correct selection
                decoration: const ShadDecoration(
                  secondaryFocusedBorder: ShadBorder.none,
                ),
                initialValue: isDiscountByPercent
                    ? PaymentScreenLocale.paymentDiscountPercent.getString(
                        context,
                      )
                    : PaymentScreenLocale.paymentDiscountAmount.getString(
                        context,
                      ), // ★ was hardcoded
                placeholder: Text(
                  PaymentScreenLocale.paymentDiscountAmount.getString(context),
                  style: const TextStyle(fontSize: 12),
                ),
                selectedOptionBuilder: (context, value) {
                  return Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );
                },
                options: [
                  PaymentScreenLocale.paymentDiscountPercent.getString(context),
                  PaymentScreenLocale.paymentDiscountAmount.getString(context),
                ].map((e) => ShadOption(value: e, child: Text(e))),
                onChanged: (value) =>
                    value ==
                        PaymentScreenLocale.paymentDiscountPercent.getString(
                          context,
                        )
                    ? onChangedSelect(true)
                    : onChangedSelect(false),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: 80,
        child: ShadInputFormField(
          key: ValueKey(
            isDiscountByPercent,
          ), // ★ forces field to rebuild fresh with new initialValue
          keyboardType: TextInputType.number,
          initialValue: initialValue(isDiscountByPercent),
          textAlign: TextAlign.right,
          decoration: ShadDecoration(secondaryFocusedBorder: ShadBorder.none),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          onChanged: (val) => onChangedInput(val),
        ),
      ),
    ],
  );
}
