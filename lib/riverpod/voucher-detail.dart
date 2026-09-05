import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/features/voucher/data/model/voucher-detail.dart';

class VoucherDetailNotifier extends Notifier<VoucherDetailModel?> {
  @override
  VoucherDetailModel? build() {
    return null;
  }

  // Set a new voucher
  void setVoucher(VoucherDetailModel voucher) {
    state = voucher;
  }

  void updateVoucher({
    List<ItemModel>? items,
    List<VoucherPayment>? payments,
    double? totalPaymentAmount,
    double? deliveryFee,
    double? packagingFee,
    double? total,
    double? subTotal,
    double? tax,
    double? discountAmount,
    double? discountPercent,
    String? note,
    String? type,
  }) {
    if (state != null) {
      state = state!.copyWith(
        items: items,
        subTotal: subTotal,
        total: total,
        tax: tax,
        note: note,
        type: type,
        payments: payments,
        totalPaymentAmount: totalPaymentAmount,
        deliveryFee: deliveryFee,
        packagingFee: packagingFee,
        discountAmount: discountAmount,
        discountPercent: discountPercent,
      );
    }
  }

  void addItem(ItemModel item) {
    if (state != null) {
      List<ItemModel> items = [...state!.items, item];
      state = state!.copyWith(items: items);
      calculate();
    }
  }

  void removeItem(int id) {
    if (state != null) {
      List<ItemModel> items = state!.items.where((e) => e.id != id).toList();
      state = state!.copyWith(items: items);
      calculate();
    }
  }

  void addPayment(VoucherPayment payment) {
    // print("payment 🥶 ${payment.paymentDataId}");
    if (state != null) {
      List<VoucherPayment> payments = [...state!.payments, payment];
      state = state!.copyWith(payments: payments);
      calculate();
    }
  }

  void updatePaymentAmount(String id, String amount) {
    if (state == null || state!.payments.isEmpty) return;

    final parsed = double.tryParse(amount) ?? 0.0;
    // print(
    //   "parsed amount is $parsed ${state?.payments[0].paymentData?.id} ${id} ${state?.payments[0].copyWith(amount: 99)}",
    // );
    state = state!.copyWith(
      payments: state!.payments
          .map(
            (e) => e.paymentData!.id.toString() == id
                ? e.copyWith(amount: parsed)
                : e,
          )
          .toList(),
    );
    calculate();
  }

  void removePaymentByid(String id) {
    print("id $id");
    if (state != null) {
      List<VoucherPayment> items = state!.payments
          .where((e) => e.paymentDataId.toString() != id)
          .toList();
      state = state!.copyWith(payments: items);
      calculate();
    }
  }

  //calculate total
  void calculate() {
    if (state != null) {
      double itemsTotal = 0;
      double paymentTotal = 0;

      for (var item in state!.items) {
        itemsTotal += (item.quantity * item.price);
      }

      for (var payment in state!.payments) {
        paymentTotal += payment.amount;
      }

      double totalPrice =
          itemsTotal +
          state!.tax +
          state!.deliveryFee +
          (state?.packagingFee ?? 0);

      // percentage-based discount, guarded against 0/negative
      double percentDiscountAmount = state!.discountPercent > 0
          ? totalPrice * (state!.discountPercent / 100)
          : 0.0;

      double totalWithTaxAndDiscount =
          totalPrice - state!.discountAmount - percentDiscountAmount;

      // clamp so total never goes negative from an overly large discount
      if (totalWithTaxAndDiscount < 0) {
        totalWithTaxAndDiscount = 0;
      }

      double remainingPaymentAmounts = totalWithTaxAndDiscount - paymentTotal;

      if (remainingPaymentAmounts < 0) {
        return;
      }

      state = state!.copyWith(
        total: totalWithTaxAndDiscount,
        subTotal: itemsTotal,
        totalPaymentAmount: paymentTotal,
        remainingPaymentAmount: remainingPaymentAmounts,
      );
    }
  }

  // Clear voucher
  void clearVoucher() {
    state = null;
  }
}

final voucherDetailProvider =
    NotifierProvider<VoucherDetailNotifier, VoucherDetailModel?>(
      VoucherDetailNotifier.new,
    );
