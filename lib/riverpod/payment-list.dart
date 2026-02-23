import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/models/payment-data.dart';

class PaymentListNotifier extends Notifier<List<PaymentData>?> {
  @override
  List<PaymentData>? build() {
    return null;
  }

  // Set a new voucher
  void setPaymentList(List<PaymentData> paymentList) {
    state = paymentList;
  }

  List<PaymentData> getPaymentList() {
    return state ?? [];
  }
}

final paymentListProvider =
    NotifierProvider<PaymentListNotifier, List<PaymentData>?>(
      PaymentListNotifier.new,
    );
