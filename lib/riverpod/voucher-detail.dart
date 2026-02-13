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

  //calculate total
  void calculate() {
    if (state != null) {
      double itemsTotal = 0;

      for (var item in state!.items) {
        itemsTotal += (item.quantity * item.price);
      }

      double totalWithTax = itemsTotal + state!.tax;

      // Update state immutably
      state = state!.copyWith(total: totalWithTax, subTotal: itemsTotal);
    }
  }

  // Clear voucher
  void clearVoucher() {
    state = null;
  }
}

final voucherDetailProvider =
    NotifierProvider.autoDispose<VoucherDetailNotifier, VoucherDetailModel?>(
      VoucherDetailNotifier.new,
    );
