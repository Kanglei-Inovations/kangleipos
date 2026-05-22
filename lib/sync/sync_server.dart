import 'dart:io';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class SyncServerService extends GetxService {
  final Logger _logger = Logger();
  HttpServer? _server;
  final List<WebSocket> _clients = [];

  Future<void> startServer(int port) async {
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      _logger.i('Sync Server running on ws://${_server!.address.address}:$port');

      _server!.listen((HttpRequest request) {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          WebSocketTransformer.upgrade(request).then(_handleWebSocket);
        } else {
          request.response
            ..statusCode = HttpStatus.forbidden
            ..close();
        }
      });
    } catch (e) {
      _logger.e('Failed to start Sync Server: $e');
    }
  }

  void _handleWebSocket(WebSocket socket) {
    _logger.i('New client connected');
    _clients.add(socket);

    socket.listen(
      (data) {
        _logger.i('Received data: $data');
        // Handle incoming delta sync payloads, resolve conflicts, and broadcast to other clients
        _broadcast(data.toString(), exclude: socket);
      },
      onDone: () {
        _logger.i('Client disconnected');
        _clients.remove(socket);
      },
      onError: (error) {
        _logger.e('WebSocket Error: $error');
        _clients.remove(socket);
      },
    );
  }

  void _broadcast(String message, {WebSocket? exclude}) {
    for (var client in _clients) {
      if (client != exclude) {
        client.add(message);
      }
    }
  }

  void stopServer() {
    _server?.close(force: true);
    for (var client in _clients) {
      client.close();
    }
    _clients.clear();
    _logger.i('Sync Server stopped');
  }
}
