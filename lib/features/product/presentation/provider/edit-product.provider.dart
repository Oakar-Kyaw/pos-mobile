// features/product/presentation/provider/edit-product.provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditingProductIdNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void startEdit(int id) {
    state = id;
  }

  void clearEdit() {
    state = null;
  }
}

final editingProductIdProvider =
    NotifierProvider<EditingProductIdNotifier, int?>(
      EditingProductIdNotifier.new,
    );
