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
  required void Function(bool) addDiscount,
  bool isDiscountByPercent = true,
}) {
  final voucher = ref.watch(voucherDetailProvider);

  String initialValue() {
    if (voucher == null) {
      return '0';
    }

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

  void onChangedInput(String value) {
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

  final isSmallScreen = MediaQuery.sizeOf(context).width < 360;

  return Row(
    children: [
      Expanded(
        child: Row(
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
              ),
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: isSmallScreen ? 90 : 100,
              child: ShadSelect<String>(
                key: ValueKey(isDiscountByPercent),
                decoration: const ShadDecoration(
                  secondaryFocusedBorder: ShadBorder.none,
                ),
                initialValue: isDiscountByPercent
                    ? PaymentScreenLocale.paymentDiscountPercent.getString(
                        context,
                      )
                    : PaymentScreenLocale.paymentDiscountAmount.getString(
                        context,
                      ),
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
                options:
                    [
                      PaymentScreenLocale.paymentDiscountPercent.getString(
                        context,
                      ),
                      PaymentScreenLocale.paymentDiscountAmount.getString(
                        context,
                      ),
                    ].map(
                      (e) => ShadOption(
                        value: e,
                        child: Text(e, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                onChanged: (value) {
                  if (value ==
                      PaymentScreenLocale.paymentDiscountPercent.getString(
                        context,
                      )) {
                    onChangedSelect(true);
                  } else {
                    onChangedSelect(false);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: isSmallScreen ? 70 : 80,
        child: ShadInputFormField(
          key: ValueKey(isDiscountByPercent),
          keyboardType: TextInputType.number,
          initialValue: initialValue(),
          textAlign: TextAlign.right,
          decoration: const ShadDecoration(
            secondaryFocusedBorder: ShadBorder.none,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*.?\d*')),
          ],
          onChanged: onChangedInput,
        ),
      ),
    ],
  );
}
