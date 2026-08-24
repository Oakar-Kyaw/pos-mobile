import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedData {
  final int? customerId;
  final int? supplierId;
  final int? userId;
  final DateTime? startDate;
  final DateTime? endDate;

  SelectedData({
    this.userId,
    this.startDate,
    this.endDate,
    this.customerId,
    this.supplierId,
  });

  SelectedData copyWith({
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? customerId,
    int? supplierId,
  }) {
    return SelectedData(
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      supplierId: supplierId ?? this.supplierId,
      customerId: customerId ?? this.customerId,
    );
  }
}

class SelectedDataNotifier extends Notifier<SelectedData?> {
  @override
  SelectedData? build() {
    return SelectedData();
  }

  void setUser(int? userId) {
    state = (state ?? SelectedData()).copyWith(userId: userId);
  }

  void clearUser() {
    final old = state;
    state = SelectedData(
      userId: null,
      supplierId: old?.supplierId,
      customerId: old?.customerId,
      startDate: old?.startDate,
      endDate: old?.endDate,
    );
  }

  void clearSupplier() {
    final old = state;
    state = SelectedData(
      supplierId: null,
      customerId: old?.customerId,
      userId: old?.userId,
      startDate: old?.startDate,
      endDate: old?.endDate,
    );
  }

  void clearCustomer() {
    final old = state;
    state = SelectedData(
      supplierId: old?.supplierId,
      customerId: null,
      userId: old?.userId,
      startDate: old?.startDate,
      endDate: old?.endDate,
    );
  }

  void setSupplierUser(int? supplierId) {
    state = (state ?? SelectedData()).copyWith(supplierId: supplierId);
  }

  void setCustomerUser(int? customerId) {
    state = (state ?? SelectedData()).copyWith(customerId: customerId);
  }

  void setStartDate(DateTime? startDate) {
    state = (state ?? SelectedData()).copyWith(startDate: startDate);
  }

  void setEndDate(DateTime? endDate) {
    state = (state ?? SelectedData()).copyWith(endDate: endDate);
  }

  void clear() {
    state = null;
  }
}

final selectedDataStateProvider =
    NotifierProvider<SelectedDataNotifier, SelectedData?>(
      SelectedDataNotifier.new,
    );
