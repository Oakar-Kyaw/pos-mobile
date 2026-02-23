import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/models/voucher-detail.dart';

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
    double? total,
    double? subTotal,
    double? tax,
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

  void removePaymentByid(String id) {
    if (state != null) {
      List<VoucherPayment> items = state!.payments
          .where((e) => e.id != id)
          .toList();
      state = state!.copyWith(payments: items);
      calculate();
    }
  }

  // void removePayment(int id) {
  //   if (state != null) {
  //     List<VoucherPayment> items = state!.payments
  //         .where((e) => e.id != id)
  //         .toList();
  //     state = state!.copyWith(items: items);
  //     calculate();
  //   }
  // }

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

      double totalWithTax = itemsTotal + state!.tax + state!.deliveryFee;
      double remainingPaymentAmounts = totalWithTax - paymentTotal;
      //print("remain $remainingPaymentAmounts $paymentTotal ");
      // Update state immutably
      state = state!.copyWith(
        total: totalWithTax,
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
