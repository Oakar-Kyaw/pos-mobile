import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedData {
  final int? userId;
  final DateTime? startDate;
  final DateTime? endDate;

  SelectedData({this.userId, this.startDate, this.endDate});

  SelectedData copyWith({int? userId, DateTime? startDate, DateTime? endDate}) {
    return SelectedData(
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
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
      startDate: old?.startDate,
      endDate: old?.endDate,
    );
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
