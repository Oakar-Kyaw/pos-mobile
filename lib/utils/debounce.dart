import 'dart:async';

Timer? debounce;

void onSearch(Future<void> Function() cb) {
  if (debounce?.isActive ?? false) {
    debounce!.cancel();
  }

  debounce = Timer(const Duration(milliseconds: 500), () async {
    await cb();
  });
}
