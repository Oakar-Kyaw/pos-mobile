import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/account.api.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/features/voucher/data/model/voucher-detail.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PaymentSelectComponent extends ConsumerStatefulWidget {
  const PaymentSelectComponent({super.key});

  @override
  ConsumerState<PaymentSelectComponent> createState() =>
      _PaymentSelectComponentState();
}

class _PaymentSelectComponentState
    extends ConsumerState<PaymentSelectComponent> {
  @override
  Widget build(BuildContext context) {
    final paymentDataAsync = ref.watch(paymentDataProvider);
    final voucher = ref.read(voucherDetailProvider.notifier);

    return paymentDataAsync.when(
      error: (error, stackTrace) => ErrorWidget("Something went wrong"),
      loading: () => LoadingWidget(),
      data: (payment) => ShadSelect<PaymentData>(
        decoration: const ShadDecoration(
          secondaryFocusedBorder: ShadBorder.none,
        ),
        placeholder: Text(
          PaymentScreenLocale.selectPaymentAccount.getString(context),
          style: const TextStyle(fontSize: 12),
        ),
        selectedOptionBuilder: (context, value) {
          return Text(value.accountName);
        },
        onChanged: (value) {
          if (value == null) return;
          //print("on changed is ${value.id}");
          voucher.addPayment(
            VoucherPayment(
              amount: 0,
              type: value.accountType,
              paymentData: value,
              paymentDataId: value.id,
            ),
          );
        },
        options: payment
            .map(
              (p) =>
                  ShadOption<PaymentData>(value: p, child: Text(p.accountName)),
            )
            .toList(),
      ),
    );
  }
}
