import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:pos/api/account.api.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/core/widgets/delete-icon.dart';
import 'package:pos/features/voucher/data/model/voucher-detail.dart';
import 'package:pos/localization/repay-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/repayment-dialog.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';

class VoucherComponent extends ConsumerStatefulWidget {
  const VoucherComponent({
    super.key,
    required this.index,
    required this.textColor,
    required this.subColor,
    required this.voucher,
    required this.pagingController,
    this.onDelete,
  });

  final Color textColor;
  final int index;
  final Color subColor;
  final VoucherDetailModel voucher;
  final PagingController<int, VoucherDetailModel> pagingController;
  final VoidCallback? onDelete;

  @override
  ConsumerState<VoucherComponent> createState() => _VoucherComponentState();
}

class _VoucherComponentState extends ConsumerState<VoucherComponent> {
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
    // Account မရွေးရသေးရင် မပို့ပါ
    if (paymentDataId == null) return;

    ref
        .read(voucherProvider.notifier)
        .createRepayment(
          paymentDataId: paymentDataId!,
          amount: amount,
          voucherId: widget.voucher.id,
        )
        .then((data) {
          if (!mounted) return;
          final ok = data["success"] == true;
          ShowToast(
            context,
            description: Text(
              (ok
                      ? RepayLocaleScreen.repaySaveSuccess
                      : RepayLocaleScreen.repaySaveFailed)
                  .getString(context),
              style: TextStyle(fontSize: FontSizeConfig.title(context)),
            ),
          );
          if (ok) {
            context.pop(context); // dialog ပိတ်
            widget.pagingController.refresh(); // list ပြန် load
          }
        })
        .onError((error, stackTrace) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $error")));
        });
  }

  void _openRepayDialog() async {
    final isDark = ref.read(themeModeProvider) == ThemeMode.dark;
    try {
      await ref.read(paymentDataProvider.future);
    } catch (_) {}
    final paymentLists = ref.read(paymentDataProvider);
    // Dialog ဖွင့်တိုင်း ကျန်ငွေကို default အဖြစ် ပြန်ထည့်
    amountController.text = widget.voucher.remainingPaymentAmount.toString();

    showPaymentDialog(
      context,
      isDark: isDark,
      paymentLists: paymentLists,
      amountController: amountController,
      remainingPaymentAmount: widget.voucher.remainingPaymentAmount,
      total: widget.voucher.total,
      changeAccountType: _changeAccountType,
      paymentDataId: paymentDataId,
      submit: _submit,
    );
  }

  void _updatePaidStatus() {
    ref
        .read(voucherProvider.notifier)
        .updatePaidStatus(widget.voucher.id)
        .then((data) {
          if (!mounted) return;
          ShowToast(
            context,
            description: Text(
              (data
                      ? VoucherScreenLocale.updatePaidStatusSuccess
                      : VoucherScreenLocale.updatePaidStatusFailed)
                  .getString(context),
              style: TextStyle(
                fontSize: FontSizeConfig.title(context),
                color: kGreen,
              ),
            ),
          );
          if (data) {
            widget.pagingController.refresh(); // list ပြန် load
          }
        })
        .onError((error, stackTrace) {
          if (!mounted) return;
          ShowToast(
            context,
            isError: true,
            description: Text(
              VoucherScreenLocale.updatePaidStatusFailed.getString(context),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final voucher = widget.voucher;
    final theme = Theme.of(context);
    final bool hasDebt = voucher.existDebt ?? false;
    final bool hasDiscount =
        voucher.discountAmount > 0 || voucher.discountPercent > 0;

    // Debt ရှိရင် အနီ၊ မရှိရင် အစိမ်း
    final Color accent = hasDebt ? Colors.redAccent : kGreen;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.pushNamed(AppRoute.receipt, extra: voucher.id),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- Header ----------
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: accent,
                          size: FontSizeConfig.iconSize3(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              voucher.voucherCode ?? "-",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: FontSizeConfig.body2(context),
                                fontWeight: FontWeight.w700,
                                color: widget.textColor,
                              ),
                            ),
                            if (voucher.createdAt != null) ...[
                              const SizedBox(height: 3),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: widget.subColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'd MMM, y',
                                    ).format(voucher.createdAt!),
                                    style: TextStyle(
                                      fontSize: FontSizeConfig.body3(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (voucher.customer != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                "${voucher.customer!.name} (${voucher.customer!.phone})",
                                style: TextStyle(
                                  fontSize: FontSizeConfig.body3(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.onDelete != null)
                        DeleteIcon(onDelete: widget.onDelete),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Divider(height: 1, color: widget.subColor.withOpacity(0.2)),
                  const SizedBox(height: 10),

                  // ---------- Footer: badges + repay + total ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Repay button (debt ရှိမှ ပြ)
                      if (hasDebt) ...[
                        FilledButton.icon(
                          onPressed: _openRepayDialog,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.payments_rounded, size: 16),
                          label: Text(
                            "",
                            style: TextStyle(
                              fontSize: FontSizeConfig.body3(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      const Spacer(),
                      //if paid
                      if (voucher.paidStatus == PaidStatus.paid)
                        Text(
                          "${voucher.total.toString()} (${voucher.paidStatus?.name.toUpperCase() ?? "N/A"})",
                          style: TextStyle(
                            fontSize: FontSizeConfig.title3(context),
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      //is unpaid
                      if (voucher.paidStatus != PaidStatus.paid)
                        Text(
                          voucher.total.toString(),
                          style: TextStyle(
                            fontSize: FontSizeConfig.title3(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),

                      const SizedBox(width: 10),
                      if (voucher.paidStatus != PaidStatus.paid)
                        FilledButton.icon(
                          onPressed: _updatePaidStatus,
                          label: Text(
                            VoucherScreenLocale.updatePaidStatus.getString(
                              context,
                            ),
                            style: TextStyle(
                              fontSize: FontSizeConfig.body3(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          icon: Icon(Icons.warning_amber_rounded, size: 16),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
