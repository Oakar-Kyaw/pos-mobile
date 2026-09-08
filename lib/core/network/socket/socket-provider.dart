import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/network/socket/sockete-client.dart';

final socketClientProvider = Provider<SocketClient>((ref) {
  final client = SocketClient();
  ref.onDispose(() {
    client.dispose();
  });
  return client;
});
