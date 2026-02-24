import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/payment-list-widget.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

class PaymentDialog {
  Future<void> show(BuildContext context, WidgetRef ref) {
    int selectResetKey = 0;

    // Read theme outside builder so it's available inside
    final isDark = ref.read(themeModeProvider) == ThemeMode.dark;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE5E7EB);

    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      backgroundColor: Colors.transparent,
      builder: (context) {
        final paymentMethodCollections = {
          'CASH': PaymentScreenLocale.paymentCash.getString(context),
          'BANK': PaymentScreenLocale.paymentBank.getString(context),
          'CARD': PaymentScreenLocale.paymentCard.getString(context),
          'EWALLET': PaymentScreenLocale.paymentEWallet.getString(context),
        };

        return Consumer(
          builder: (context, ref, _) {
            final voucher = ref.watch(voucherDetailProvider);

            return StatefulBuilder(
              builder: (context, setState) {
                return AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.15),
                            blurRadius: 24,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 8,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── Drag handle ──────────────────────
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 6,
                                ),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),

                            // ── Close + Title row ────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Section accent label
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [kPrimary, kSecondary],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        PaymentScreenLocale.paymentDescription
                                            .getString(context),
                                        style: TextStyle(
                                          fontSize: FontSizeConfig.title(
                                            context,
                                          ),
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Close button
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.08)
                                          : Colors.black.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      LucideIcons.x,
                                      size: FontSizeConfig.iconSize(context),
                                      color: subColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── Summary card ─────────────────────
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(
                                  isDark ? 0.15 : 0.06,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: kPrimary.withOpacity(
                                    isDark ? 0.25 : 0.12,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Total
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        PaymentScreenLocale.paymentTotalAmount
                                            .getString(context),
                                        style: TextStyle(
                                          fontSize: FontSizeConfig.body(
                                            context,
                                          ),
                                          fontWeight: FontWeight.w600,
                                          color: subColor,
                                        ),
                                      ),
                                      Text(
                                        voucher!.total.toStringAsFixed(2),
                                        style: TextStyle(
                                          fontSize: FontSizeConfig.title(
                                            context,
                                          ),
                                          fontWeight: FontWeight.w800,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Divider(height: 20, color: dividerColor),

                                  // Remaining
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        PaymentScreenLocale
                                            .paymentRemainingAmount
                                            .getString(context),
                                        style: TextStyle(
                                          fontSize: FontSizeConfig.body(
                                            context,
                                          ),
                                          fontWeight: FontWeight.w600,
                                          color: subColor,
                                        ),
                                      ),
                                      Text(
                                        voucher.remainingPaymentAmount
                                            .toStringAsFixed(2),
                                        style: TextStyle(
                                          fontSize: FontSizeConfig.title(
                                            context,
                                          ),
                                          fontWeight: FontWeight.w800,
                                          color:
                                              voucher.remainingPaymentAmount > 0
                                              ? kAmber
                                              : kGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── Payment list ─────────────────────
                            const PaymentListWidget(),

                            const SizedBox(height: 12),

                            // ── Payment method select ─────────────
                            ShadSelect<String>(
                              key: ValueKey(selectResetKey),
                              placeholder: Text(
                                PaymentScreenLocale.selectPaymentMethod
                                    .getString(context),
                                style: TextStyle(color: subColor),
                              ),
                              selectedOptionBuilder: (context, value) =>
                                  Text(paymentMethodCollections[value]!),
                              onChanged: (value) {
                                if (value == null) return;
                                ref
                                    .read(voucherDetailProvider.notifier)
                                    .addPayment(
                                      VoucherPayment(
                                        id: const Uuid().v4(),
                                        amount: 0,
                                        paymentDataId: 0,
                                        type: value,
                                      ),
                                    );
                                setState(() => selectResetKey++);
                              },
                              options: paymentMethodCollections.entries.map(
                                (e) => ShadOption(
                                  value: e.key,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _paymentIcon(e.key),
                                          size: 16,
                                          color: kPrimary,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(e.value),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Confirm button ───────────────────
                            SizedBox(
                              width: double.infinity,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [kPrimary, kSecondary],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kPrimary.withOpacity(0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ShadButton(
                                  backgroundColor: Colors.transparent,
                                  onPressed: () {
                                    final payments = voucher.payments;
                                    final existPayments = payments.any(
                                      (e) => e.paymentDataId != 0,
                                    );

                                    if (!existPayments) {
                                      ShowToast(
                                        context,
                                        description: Text(
                                          PaymentScreenLocale
                                              .selectPaymentMethod
                                              .getString(context),
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: FontSizeConfig.body(
                                              context,
                                            ),
                                          ),
                                        ),
                                        borderColor: Colors.red,
                                        action: Icon(
                                          LucideIcons.x,
                                          color: Colors.red,
                                          size: FontSizeConfig.iconSize(
                                            context,
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    context.pop();
                                  },
                                  child: Text(
                                    PaymentScreenLocale.paymentButton.getString(
                                      context,
                                    ),
                                    style: TextStyle(
                                      fontSize: FontSizeConfig.body(context),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
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
}
