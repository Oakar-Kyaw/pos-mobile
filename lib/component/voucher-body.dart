import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/account.api.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/localization/repay-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:pos/utils/repayment-dialog.dart';
import 'package:pos/utils/shad-toaster.dart';

class AmountSection extends ConsumerStatefulWidget {
  AmountSection({
    required this.voucher,
    required this.hasDebt,
    required this.pagingController,
    this.showButton = false,
    super.key,
  });

  final VoucherDetailModel voucher;
  final bool hasDebt;
  final bool showButton;
  PagingController<int, VoucherDetailModel> pagingController;

  @override
  ConsumerState<AmountSection> createState() => _AmountSectionState();
}

class _AmountSectionState extends ConsumerState<AmountSection> {
  String? paymentType;
  int? paymentDataId;
  late TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
      text: widget.voucher.remainingPaymentAmount.toString(),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void _changeAccountType(String? value) {
    if (value == null) return;
    final data = PaymentData.fromJson(jsonDecode(value));
    setState(() {
      paymentType = data.accountType;
      paymentDataId = data.id;
    });
  }

  void _submit(double amount) async {
    final payload = {
      "voucherId": widget.voucher.id,
      "amount": amount,
      "paymentDataId": paymentDataId,
    };

    debugPrint("🟢 Refund Payload => $payload");

    ref
        .read(voucherProvider.notifier)
        .createRepayment(
          paymentDataId: paymentDataId!,
          amount: amount,
          voucherId: widget.voucher.id,
        )
        .then((data) {
          if (data["success"]) {
            ShowToast(
              context,
              description: Text(
                RepayLocaleScreen.repaySaveSuccess.getString(context),
                style: TextStyle(fontSize: FontSizeConfig.title(context)),
              ),
            );
            context.pop(context);
            widget.pagingController.refresh();
          } else {
            ShowToast(
              context,
              description: Text(
                RepayLocaleScreen.repaySaveFailed.getString(context),
                style: TextStyle(fontSize: FontSizeConfig.title(context)),
              ),
            );
          }
        })
        .onError((error, stackTrace) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $error")));
        });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    AsyncValue<List<PaymentData>> paymentLists = ref.watch(paymentDataProvider);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AmountChip(
                label: PaymentScreenLocale.paidAmount.getString(context),
                value: formatAmount(widget.voucher.totalPaymentAmount),
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _AmountChip(
                label: PaymentScreenLocale.paymentRemainingAmount.getString(
                  context,
                ),
                value: formatAmount(widget.voucher.remainingPaymentAmount),
                color: widget.hasDebt ? Colors.red : Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        widget.showButton
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => showPaymentDialog(
                    context,
                    isDark: isDark,
                    paymentLists: paymentLists,
                    amountController: amountController,
                    remainingPaymentAmount:
                        widget.voucher.remainingPaymentAmount,
                    total: widget.voucher.total,
                    changeAccountType: _changeAccountType,
                    paymentDataId: paymentDataId,
                    submit: _submit,
                  ),
                  icon: const Icon(Icons.payments_rounded, size: 18),
                  label: Text(
                    PaymentScreenLocale.paymentTitle.getString(context),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            : SizedBox(),
      ],
    );
  }
}

// ────────── Chips and Dialog Rows ──────────

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: FontSizeConfig.body(context),
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class DialogAmountRow extends StatelessWidget {
  const DialogAmountRow({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
