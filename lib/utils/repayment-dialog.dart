import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/component/voucher-body.dart';
import 'package:pos/localization/payment-data-local.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:pos/utils/payment-icon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void showPaymentDialog(
  BuildContext context, {
  required bool isDark,
  required AsyncValue<List<PaymentData>> paymentLists,
  required double remainingPaymentAmount,
  required TextEditingController amountController,
  required double total,
  required changeAccountType,
  required submit,
  int? paymentDataId,
}) {
  amountController.text = remainingPaymentAmount.toString();

  final subColor = isDark ? kTextSubDark : kTextSubLight;
  final progressIndicatorColor = isDark ? kPrimary : kPrimary.withOpacity(0.8);

  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.payments_rounded,
                      color: kPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    PaymentScreenLocale.paymentTitle.getString(context),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DialogAmountRow(
                        label: VoucherScreenLocale.total.getString(context),
                        value: formatAmount(total),
                        color: kPrimary,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: Colors.grey.shade200,
                    ),
                    Expanded(
                      child: DialogAmountRow(
                        label: PaymentScreenLocale.paymentRemainingAmount
                            .getString(context),
                        value: formatAmount(remainingPaymentAmount),
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Amount label
              Text(
                PaymentScreenLocale.paymentAmount.getString(context),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Amount input
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixIcon: Icon(
                    Icons.attach_money_rounded,
                    color: kPrimary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: kPrimary.withOpacity(0.04),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kPrimary.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kPrimary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Account type select
              paymentLists.when(
                data: (paymentList) => ShadSelect<String>(
                  minWidth: double.infinity,
                  placeholder: Text(
                    PaymentDataLocale.type.getString(context),
                    style: TextStyle(color: isDark ? Colors.white : subColor),
                  ),
                  selectedOptionBuilder: (context, value) {
                    final selected = PaymentData.fromJson(jsonDecode(value));
                    return Text(selected.accountName);
                  },
                  onChanged: changeAccountType,
                  options: paymentList
                      .map<ShadOption<String>>(
                        (e) => ShadOption(
                          value: jsonEncode(e),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      paymentIcon(e.accountName),
                                      size: 16,
                                      color: kPrimary,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(e.accountName),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      e.accountType,
                                      style: TextStyle(
                                        color: subColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      e.accountNumber ?? '',
                                      style: TextStyle(
                                        color: subColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                loading: () => Center(
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      color: progressIndicatorColor,
                    ),
                  ),
                ),
                error: (error, stack) =>
                    Text("Error loading payment list: $error"),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        PaymentScreenLocale.cancel.getString(context),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(amountController.text);
                        if (amount == null || amount <= 0) return;
                        // Navigator.pop(context, {
                        //   "amount": amount,
                        //   "paymentDataId": paymentDataId,
                        // });
                        submit.call(amount);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        PaymentScreenLocale.paymentTitle.getString(context),
                        style: const TextStyle(fontWeight: FontWeight.w700),
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
  );
}
