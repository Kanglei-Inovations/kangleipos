import 'dart:io';
import 'package:get/get.dart';
import '../../../sync/sync_server.dart';
import '../../../sync/sync_client.dart';

class SyncController extends GetxController {
  late final SyncServerService _server;
  late final SyncClientService _client;

  final RxBool isDesktop = false.obs;
  final RxBool isServerRunning = false.obs;
  final RxBool isConnected = false.obs;
  final RxBool isSyncing = false.obs;
  final RxString syncStatus = 'Ready'.obs;
  final RxDouble syncProgress = 0.0.obs;
  final RxString lastSyncTime = 'Never'.obs;
  final RxString localIp = ''.obs;
  final RxString serverToken = ''.obs;
  final RxString qrData = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _server = Get.find<SyncServerService>();
    _client = Get.find<SyncClientService>();

    isDesktop.value = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    // Mirror reactive values from services
    ever(_server.isRunning, (v) => isServerRunning.value = v);
    ever(_client.isSyncing, (v) => isSyncing.value = v);
    ever(_client.syncStatus, (v) => syncStatus.value = v);
    ever(_client.syncProgress, (v) => syncProgress.value = v);
    ever(_client.lastSyncTime, (v) => lastSyncTime.value = v);
    ever(_server.serverIp, (v) {
      localIp.value = v;
      qrData.value = _server.qrPayload;
    });
    ever(_server.serverToken, (v) {
      serverToken.value = v;
      qrData.value = _server.qrPayload;
    });

    localIp.value = _server.serverIp.value;
    serverToken.value = _server.serverToken.value;
    qrData.value = _server.qrPayload;
  }

  Future<void> startDesktopServer() async {
    await _server.startServer();
    qrData.value = _server.qrPayload;
  }

  void stopDesktopServer() {
    _server.stopServer();
  }

  /// Called when mobile scans the QR code
  Future<bool> connectAndSync(String ip, int port, String token) async {
    _client.configure(ip, port, token);
    isConnected.value = true;
    return await _client.syncFromDesktop();
  }

  Future<bool> syncNow() async {
    if (!isConnected.value) {
      syncStatus.value = 'Not connected. Scan QR code first.';
      return false;
    }
    return await _client.syncFromDesktop();
  }

  Future<bool> checkConnection() async {
    if (!isConnected.value) return false;
    return await _client.ping();
  }

  void startHost() {
    startDesktopServer();
  }

  void connectToHost(String ip) {
    _client.connectToServer(ip, 8765);
    isConnected.value = true;
  }
}
