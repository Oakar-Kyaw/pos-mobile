import 'package:flutter_riverpod/flutter_riverpod.dart';

class LowStockSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setSearch(String value) {
    state = value;
  }

  void clear() {
    state = '';
  }
}

final lowStockSearchProvider = NotifierProvider<LowStockSearchNotifier, String>(
  LowStockSearchNotifier.new,
);
