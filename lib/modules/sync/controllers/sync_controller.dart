import 'package:get/get.dart';
import '../../../sync/sync_server.dart';
import '../../../sync/sync_client.dart';
import 'dart:io';

class SyncController extends GetxController {
  final SyncServerService _server = Get.find<SyncServerService>();
  final SyncClientService _client = Get.find<SyncClientService>();

  final RxString localIp = 'Unknown'.obs;
  final RxBool isServerRunning = false.obs;
  final RxBool isClientConnected = false.obs;
  final RxList<String> connectedClients = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _getHostIp();
  }

  Future<void> _getHostIp() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            localIp.value = addr.address;
          }
        }
      }
    } catch (e) {
      localIp.value = '127.0.0.1';
    }
  }

  void startHost() {
    _server.startServer(8080);
    isServerRunning.value = true;
  }

  void connectToHost(String ip) {
    _client.connectToServer(ip, 8080);
    isClientConnected.value = true;
  }
}
