import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final internetServiceProvider = StreamProvider<bool>((ref) async* {
  final checker = InternetConnection();
  yield await checker.hasInternetAccess;
  await for (final status in checker.onStatusChange) {
    yield status == InternetStatus.connected;
  }
});
