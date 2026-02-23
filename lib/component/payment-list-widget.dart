import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/component/payment-voucher-widget.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';

class PaymentListWidget extends ConsumerWidget {
  const PaymentListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucher = ref.watch(voucherDetailProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    if (voucher == null || voucher.payments.isEmpty) {
      return const SizedBox();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: voucher.payments.length,
      separatorBuilder: (_, __) => Divider(
        height: 24,
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : const Color(0xFFF3F4F6),
      ),
      itemBuilder: (context, index) {
        final payment = voucher.payments[index];
        return PaymentVoucherWidget(
          key: ValueKey(payment.id),
          payment: payment,
        );
      },
    );
  }
}
