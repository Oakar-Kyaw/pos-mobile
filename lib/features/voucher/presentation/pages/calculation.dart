import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/features/customer/data/model/customer-model.dart';
import 'package:pos/features/voucher/presentation/widgets/calculation-row-delivery-fee.dart';
import 'package:pos/features/voucher/presentation/widgets/calculation-row-discount.dart';
import 'package:pos/features/voucher/presentation/widgets/calculation-row-note.dart';
import 'package:pos/features/voucher/presentation/widgets/calculation-row-packagin-fee.dart';
import 'package:pos/features/voucher/presentation/widgets/calculation-row-payment.dart';
import 'package:pos/features/voucher/presentation/widgets/calculation-row-tax.dart';
import 'package:pos/features/voucher/presentation/widgets/calculation-row.dart';
import 'package:pos/features/voucher/presentation/widgets/calculation-selection-label.dart';
import 'package:pos/features/voucher/presentation/widgets/voucher-customer.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/payment-select.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VoucherCalculationDialog extends ConsumerStatefulWidget {
  final List<File> photos;
  const VoucherCalculationDialog({super.key, required this.photos});

  @override
  ConsumerState<VoucherCalculationDialog> createState() =>
      _VoucherCalculationDialogState();
}

class _VoucherCalculationDialogState
    extends ConsumerState<VoucherCalculationDialog> {
  bool isDiscountByPercent = true;
  int? customerId;
  Customer? newCustomer;

  void handleChangeAmount(String voucherId, String value) {
    final vd = ref.read(voucherDetailProvider.notifier);
    vd.updatePaymentAmount(voucherId, value);
  }

  void _addDiscount(bool val) => setState(() {
    isDiscountByPercent = val;
  });

  void saveVoucher() async {
    try {
      final voucher = ref.watch(voucherDetailProvider);
      if (voucher == null) return;
      final saveVoucherApi = await ref
          .read(voucherProvider.notifier)
          .postVoucher(
            voucher: voucher,
            files: widget.photos,
            customerId: customerId,
            customer: newCustomer,
          );
      if (saveVoucherApi["success"]) {
        ShowToast(
          context,
          description: Text(
            VoucherScreenLocale.createdSuccess.getString(context),
            style: TextStyle(fontSize: FontSizeConfig.body(context)),
          ),
          action: Icon(
            LucideIcons.circleCheck,
            color: kGreen,
            size: FontSizeConfig.iconSize(context),
          ),
        );
        context.pushReplacement(AppRoute.receipt, extra: saveVoucherApi["id"]);
      } else {
        ShowToast(
          context,
          isError: true,
          description: Text(
            VoucherScreenLocale.successFailed.getString(context),
            style: TextStyle(fontSize: FontSizeConfig.body(context)),
          ),
          action: Icon(
            LucideIcons.circleCheck,
            color: kRed,
            size: FontSizeConfig.iconSize(context),
          ),
        );
        return;
      }
    } on DioException catch (e) {
      String errorMessage = 'Voucher creation failed';

      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map;
        errorMessage = data['message']?.toString() ?? errorMessage;
      }

      debugPrint("Voucher Creation Failed 😣 $errorMessage");

      // Show it to the user
      if (context.mounted) {
        ShowToast(
          context,
          isError: true,
          description: Text(
            errorMessage,
            style: TextStyle(
              fontSize: FontSizeConfig.body(context),
              color: kRed,
            ),
          ),
          action: Icon(
            LucideIcons.circleCheck,
            color: kRed,
            size: FontSizeConfig.iconSize(context),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        "Voucher Creation Failed 😣 ${e.toString()} ${e.toString() == "Insufficient stock for item L'Oreal ခရမ်"}",
      );

      ShowToast(
        context,
        isError: true,
        description: Text(
          VoucherScreenLocale.somethingWentWrong.getString(context),
          style: TextStyle(fontSize: FontSizeConfig.body(context), color: kRed),
        ),
        action: Icon(
          LucideIcons.circleCheck,
          color: kRed,
          size: FontSizeConfig.iconSize(context),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final voucher = ref.watch(voucherDetailProvider);
    final notifier = ref.read(voucherDetailProvider.notifier);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE5E7EB);
    // print("by discount $isDiscountByPercent");
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Totals card ────────────────────
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? kPrimary.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    rowTax(
                      ref,
                      VoucherScreenLocale.tax.getString(context),
                      textColor,
                    ),
                    const SizedBox(height: 10),
                    rowDeliveryFee(
                      ref,
                      PaymentScreenLocale.deliveryFee.getString(context),
                      textColor,
                    ),
                    const SizedBox(height: 10),

                    rowPackaginFee(
                      ref,
                      VoucherScreenLocale.packagingFee.getString(context),
                      textColor,
                    ),
                    const SizedBox(height: 10),

                    rowDiscount(
                      context,
                      ref,
                      PaymentScreenLocale.paymentDiscount.getString(context),
                      textColor,
                      addDiscount: (bool val) => _addDiscount(val),
                      isDiscountByPercent: isDiscountByPercent,
                    ),
                    const SizedBox(height: 10),
                    row(
                      context,
                      VoucherScreenLocale.total.getString(context),
                      voucher!.total,
                      textColor,
                      kPrimary,
                      highlight: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              CustomerVoucher(
                onChanged: (Customer customer) {
                  setState(() {
                    //if customerId = 0 then this is local value then sendCustomer
                    customer.id == 0
                        ? newCustomer = customer
                        : customerId = customer.id;
                  });
                },
              ),
              const SizedBox(height: 10),

              // ── Section label ──────────────────
              sectionLabel(
                PaymentScreenLocale.paymentTitle.getString(context),
                textColor,
              ),
              const SizedBox(height: 12),

              // ── Payment card ────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? kPrimary.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: double.infinity,
                      child: PaymentSelectComponent(),
                    ),
                    const SizedBox(height: 12),

                    ...voucher.payments.map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            rowPayment(
                              e.paymentData!.id.toString(),
                              e.paymentData?.accountName ?? "None",
                              e.amount,
                              textColor,
                              Colors.black,
                              handleChangeAmount: (id, val) =>
                                  handleChangeAmount(id, val),
                            ),
                            Positioned(
                              top: -10,
                              right: -8,
                              child: GestureDetector(
                                onTap: () => notifier.removePaymentByid(
                                  e.paymentDataId.toString(),
                                ),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    LucideIcons.x,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Divider(height: 24, color: dividerColor),

                    row(
                      context,
                      PaymentScreenLocale.paidAmount.getString(context),
                      voucher.totalPaymentAmount,
                      textColor,
                      kGreen,
                    ),
                    const SizedBox(height: 10),
                    row(
                      context,
                      PaymentScreenLocale.paymentRemainingAmount.getString(
                        context,
                      ),
                      voucher.remainingPaymentAmount,
                      textColor,
                      kAmber,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // // ── Photo section ──────────────────
              // sectionLabel(
              //   PaymentScreenLocale.paymentPhoto.getString(context),
              //   textColor,
              // ),
              // const SizedBox(height: 12),

              // // --- Payment Photo (placeholder, add back when ready) ---
              // const SizedBox(height: 16),

              // ── Note ──────────────────────────
              rowNote(
                ref,
                VoucherScreenLocale.note.getString(context),
                textColor,
              ),

              const SizedBox(height: 16),

              // ── Save button ───────────────────
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
                    onPressed: () => saveVoucher(),
                    child: Text(
                      VoucherScreenLocale.save.getString(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
