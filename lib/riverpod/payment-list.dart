import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/models/payment-data.dart';

class PaymentListNotifier extends Notifier<List<PaymentData>> {
  @override
  List<PaymentData> build() {
    return getPaymentList();
  }

  // Set a new voucher
  void setPaymentList(List<PaymentData> paymentList) {
    print("Setting payment list with ${paymentList.length} items");
    state = paymentList;
  }

  List<PaymentData> getPaymentList() {
    return state;
  }
}

final paymentListProvider =
    NotifierProvider<PaymentListNotifier, List<PaymentData>?>(
      PaymentListNotifier.new,
    );
