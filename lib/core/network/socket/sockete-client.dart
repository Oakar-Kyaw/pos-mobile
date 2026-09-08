import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {
  io.Socket? _socket;

  final StreamController<Map<String, dynamic>> _productProgressController =
      StreamController<Map<String, dynamic>>.broadcast();

  io.Socket get socket {
    if (_socket == null) {
      throw Exception('Socket has not been initialized');
    }

    return _socket!;
  }

  Stream<Map<String, dynamic>> get productProgressStream =>
      _productProgressController.stream;

  void connect({required String baseUrl, required int userId, String? token}) {
    if (_socket != null) {
      return;
    }

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({if (token != null) 'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      print('🟢 Socket connected');
      print('Socket ID: ${_socket!.id}');

      joinUserRoom(userId);
    });

    _socket!.on('send_progress', (data) {
      print('📦 Product progress received: $data');

      _productProgressController.add(Map<String, dynamic>.from(data));
    });

    _socket!.onDisconnect((reason) {
      print('🔴 Socket disconnected: $reason');
    });

    _socket!.onConnectError((error) {
      print('❌ Socket connection error: $error');
    });
  }

  void joinUserRoom(int userId) {
    _socket?.emit('join', {'userId': userId});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();

    _socket = null;
  }

  void dispose() {
    disconnect();
    _productProgressController.close();
  }
}
