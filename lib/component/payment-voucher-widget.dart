import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/payment-data.api.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PaymentVoucherWidget extends ConsumerStatefulWidget {
  final VoucherPayment payment;

  const PaymentVoucherWidget({super.key, required this.payment});

  @override
  ConsumerState<PaymentVoucherWidget> createState() =>
      _PaymentVoucherWidgetState();
}

class _PaymentVoucherWidgetState extends ConsumerState<PaymentVoucherWidget> {
  int? selectedPaymentId;
  bool showInputAmount = false;

  void onAmountChanged(String v, VoucherDetailModel voucher) {
    if (!mounted) return;
    final amount = double.tryParse(v) ?? 0;

    final otherPaymentsTotal = voucher.payments
        .where((e) => e.id != widget.payment.id)
        .fold<double>(0, (sum, e) => sum + e.amount);

    final newTotal = otherPaymentsTotal + amount;
    if (newTotal > voucher.total) {
      ShowToast(
        context,
        description: Text(
          PaymentScreenLocale.paymentAmountExceedError.getString(context),
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: FontSizeConfig.body(context),
          ),
        ),
        borderColor: Colors.red,
        action: Icon(
          LucideIcons.x,
          color: Colors.red,
          size: FontSizeConfig.iconSize(context),
        ),
      );
      return;
    }

    ref
        .read(voucherDetailProvider.notifier)
        .updateVoucher(
          payments: voucher.payments
              .map(
                (e) =>
                    e.id == widget.payment.id ? e.copyWith(amount: amount) : e,
              )
              .toList(),
        );
    ref.read(voucherDetailProvider.notifier).calculate();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedPaymentId = widget.payment.paymentDataId == 0
            ? null
            : widget.payment.paymentDataId;
        if (widget.payment.paymentDataId != 0) showInputAmount = true;
      });
    });
  }

  IconData _paymentIcon(String type) {
    switch (type) {
      case 'CASH':
        return LucideIcons.banknote;
      case 'BANK':
        return LucideIcons.landmark;
      case 'CARD':
        return LucideIcons.creditCard;
      case 'EWALLET':
        return LucideIcons.wallet;
      default:
        return LucideIcons.circleDollarSign;
    }
  }

  @override
  Widget build(BuildContext context) {
    final voucher = ref.watch(voucherDetailProvider);
    final paymentDataAsync = ref.watch(paymentDataProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final cardBg = isDark
        ? kPrimary.withOpacity(0.08)
        : kPrimary.withOpacity(0.04);
    final cardBorder = isDark
        ? kPrimary.withOpacity(0.2)
        : kPrimary.withOpacity(0.12);

    final paymentMethodCollections = {
      'CASH': PaymentScreenLocale.paymentCash.getString(context),
      'BANK': PaymentScreenLocale.paymentBank.getString(context),
      'CARD': PaymentScreenLocale.paymentCard.getString(context),
      'EWALLET': PaymentScreenLocale.paymentEWallet.getString(context),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Payment type badge ──────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _paymentIcon(widget.payment.type),
                      color: kPrimary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    paymentMethodCollections[widget.payment.type]!,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: FontSizeConfig.body(context),
                      color: textColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Account select + Amount row ─────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Account dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PaymentScreenLocale.selectPaymentAccount.getString(
                            context,
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: subColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        paymentDataAsync.when(
                          data: (data) {
                            final filteredAccounts = data
                                .where(
                                  (e) =>
                                      e.accountType.toUpperCase() ==
                                      widget.payment.type.toUpperCase(),
                                )
                                .toList();

                            return ShadSelect<int>(
                              decoration: const ShadDecoration(
                                secondaryFocusedBorder: ShadBorder.none,
                              ),
                              initialValue: widget.payment.paymentDataId == 0
                                  ? null
                                  : widget.payment.paymentDataId,
                              placeholder: Text(
                                PaymentScreenLocale.selectPaymentAccount
                                    .getString(context),
                                style: TextStyle(color: subColor, fontSize: 12),
                              ),
                              selectedOptionBuilder: (context, value) {
                                final selected = filteredAccounts.firstWhere(
                                  (e) => e.id == value,
                                );
                                return Text(
                                  selected.accountName,
                                  style: TextStyle(color: textColor),
                                );
                              },
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  selectedPaymentId = value;
                                  showInputAmount = true;
                                });
                                ref
                                    .read(voucherDetailProvider.notifier)
                                    .updateVoucher(
                                      payments: voucher!.payments
                                          .map(
                                            (e) => e.id == widget.payment.id
                                                ? e.copyWith(
                                                    paymentDataId: value,
                                                  )
                                                : e,
                                          )
                                          .toList(),
                                    );
                              },
                              options: filteredAccounts
                                  .map(
                                    (e) => ShadOption<int>(
                                      value: e.id,
                                      child: Text(e.accountName),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                          loading: () => SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kPrimary,
                            ),
                          ),
                          error: (_, __) => Text(
                            "Failed to load accounts",
                            style: TextStyle(color: subColor, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount input
                  if (showInputAmount) ...[
                    const SizedBox(width: 16),

                    // ✅ Wrap second column with Expanded too
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PaymentScreenLocale.paymentAmount.getString(
                              context,
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: subColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ✅ Remove fixed width
                          ShadInputFormField(
                            alignment: Alignment.centerRight,
                            initialValue: widget.payment.amount == 0
                                ? "0"
                                : widget.payment.amount.toString(),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (v) => onAmountChanged(v, voucher!),
                            decoration: const ShadDecoration(
                              secondaryFocusedBorder: ShadBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // ── Remove button ───────────────────────────
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => ref
                  .read(voucherDetailProvider.notifier)
                  .removePaymentByid(widget.payment.id!),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.x,
                  size: FontSizeConfig.iconSize(context),
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
