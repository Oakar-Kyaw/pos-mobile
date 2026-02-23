import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/riverpod/payment-list.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PaymentInVoucherWidget extends ConsumerWidget {
  const PaymentInVoucherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucher = ref.watch(voucherDetailProvider);
    final paymentList = ref.read(paymentListProvider.notifier).getPaymentList();
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    // ── Empty state ──────────────────────────────
    if (voucher == null || voucher.payments.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.wallet, color: kPrimary, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              PaymentScreenLocale.noPayment.getString(context),
              style: TextStyle(
                fontSize: FontSizeConfig.body(context),
                color: subColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: voucher.payments.length,
      separatorBuilder: (_, __) => Divider(
        height: 16,
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : const Color(0xFFF3F4F6),
      ),
      itemBuilder: (context, index) {
        final payment = voucher.payments[index];

        // ── Unpicked payment ─────────────────────
        if (payment.paymentDataId == 0) {
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.circleDollarSign,
                  color: kAmber,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                PaymentScreenLocale.noPayment.getString(context),
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  color: subColor,
                ),
              ),
            ],
          );
        }

        final selected = paymentList.firstWhere(
          (e) => e.id == payment.paymentDataId,
        );

        // ── Payment row ──────────────────────────
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: kGreen.withOpacity(isDark ? 0.1 : 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kGreen.withOpacity(isDark ? 0.2 : 0.12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      LucideIcons.circleCheck,
                      color: kGreen,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    selected.accountName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: FontSizeConfig.body(context),
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Text(
                payment.amount.toStringAsFixed(2),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: FontSizeConfig.body(context),
                  color: kGreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
