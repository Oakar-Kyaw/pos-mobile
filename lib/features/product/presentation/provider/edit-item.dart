import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditingProductNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void startEdit(int id) {
    state = id;
  }

  void clearEdit() {
    state = null;
  }
}

final editingProductIdProvider = NotifierProvider<EditingProductNotifier, int?>(
  EditingProductNotifier.new,
);
