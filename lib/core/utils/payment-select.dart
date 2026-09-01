import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/account.api.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PaymentSelect extends ConsumerStatefulWidget {
  PaymentSelect({
    super.key,
    required this.onChanged,
    this.allPayment = true,
    this.initialValue,
  });

  final Function(PaymentData) onChanged;

  /// show "All" option or not
  bool allPayment;

  /// initial value
  final String? initialValue;

  @override
  ConsumerState<PaymentSelect> createState() => _PaymentSelectState();
}

class _PaymentSelectState extends ConsumerState<PaymentSelect> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();

    selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant PaymentSelect oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        selectedValue = widget.initialValue;
      });
    }
  }

  void _onChanged({required List<PaymentData> paymentList, String? value}) {
    debugPrint("🟢 _onChanged called with $value");
    setState(() {
      selectedValue = value;
    });
    final payment = paymentList.firstWhere((p) => p.id.toString() == value);
    widget.onChanged.call(payment);
  }

  @override
  Widget build(BuildContext context) {
    final paymentAsync = ref.watch(paymentDataProvider);

    return paymentAsync.when(
      data: (payments) {
        /// Build options list
        final List<ShadOption<String>> shadOptions = [
          //exist all
          if (widget.allPayment)
            ShadOption<String>(
              value: '',
              child: Text(GeneralScreenLocale.all.getString(context)),
            ),

          //if not exist
          if (!widget.allPayment)
            ShadOption<String>(
              value: '',
              child: Text(GeneralScreenLocale.selectPayment.getString(context)),
            ),

          ...payments.map(
            (p) => ShadOption<String>(
              value: p.id.toString(),
              child: Text(p.accountName),
            ),
          ),
        ];

        if (shadOptions.isEmpty) {
          return SizedBox(
            width: double.infinity,
            child: Text(PaymentScreenLocale.paymentMethod.getString(context)),
          );
        }

        /// default selection
        if (selectedValue == null ||
            !shadOptions.any((o) => o.value == selectedValue)) {
          selectedValue = shadOptions.first.value;
        }
        return ShadSelect<String>(
          initialValue: selectedValue,
          options: shadOptions,
          placeholder: Text(
            PaymentScreenLocale.selectPaymentMethod.getString(context),
          ),
          onChanged: (value) => _onChanged(paymentList: payments, value: value),
          selectedOptionBuilder: (context, value) {
            final option = shadOptions.firstWhere(
              (o) => o.value == value,
              orElse: () => ShadOption<String>(
                value: '',
                child: Text(
                  PaymentScreenLocale.paymentMethod.getString(context),
                ),
              ),
            );

            return option.child;
          },
        );
      },
      loading: () => const SizedBox(width: 100, child: LoadingWidget()),
      error: (err, stack) {
        return SizedBox(width: 200, child: Text('Error: $err'));
      },
    );
  }
}
