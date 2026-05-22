import 'dart:io';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class SyncClientService extends GetxService {
  final Logger _logger = Logger();
  WebSocket? _socket;

  Future<void> connectToServer(String ip, int port) async {
    try {
      _logger.i('Connecting to ws://$ip:$port');
      _socket = await WebSocket.connect('ws://$ip:$port');
      _logger.i('Connected to Sync Server successfully');

      _socket!.listen(
        (data) {
          _logger.i('Received delta sync: $data');
          // Apply changes to local Drift database
        },
        onDone: () {
          _logger.w('Disconnected from Server');
          _reconnect(ip, port);
        },
        onError: (error) {
          _logger.e('Connection error: $error');
        },
      );
    } catch (e) {
      _logger.e('Failed to connect: $e');
      _reconnect(ip, port);
    }
  }

  void _reconnect(String ip, int port) {
    Future.delayed(const Duration(seconds: 5), () {
      _logger.i('Attempting to reconnect...');
      connectToServer(ip, port);
    });
  }

  void sendDelta(String jsonPayload) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      _socket!.add(jsonPayload);
    } else {
      _logger.w('Socket not open. Queuing for background sync.');
      // Add to local SQLite sync queue
    }
  }

  void disconnect() {
    _socket?.close();
    _logger.i('Disconnected');
  }
}
