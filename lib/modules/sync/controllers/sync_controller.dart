import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../database/database.dart';
import '../../../sync/sync_server.dart';
import '../../../sync/sync_client.dart';

class SyncController extends GetxController {
  late final SyncServerService _server;
  late final SyncClientService _client;

  final RxBool isDesktop = false.obs;
  final RxBool isServerRunning = false.obs;
  final RxBool isConnected = false.obs;
  final RxBool isSyncing = false.obs;
  final RxBool isPulling = false.obs;
  final RxBool isPushing = false.obs;
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
    ever(_client.isSyncing, (v) => isSyncing.value = v || isPulling.value || isPushing.value);
    ever(_client.syncStatus, (v) => syncStatus.value = v);
    ever(_client.syncProgress, (v) => syncProgress.value = v);
    ever(_client.lastSyncTime, (v) => lastSyncTime.value = v);
    ever(_client.isConnected, (v) => isConnected.value = v);
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
    isServerRunning.value = _server.isRunning.value;
    isConnected.value = _client.isConnected.value;

    if (isDesktop.value && !_server.isRunning.value) {
      _server.startServer();
    } else if (!isDesktop.value) {
      _client.checkConnection();
    }
  }

  Future<void> startDesktopServer() async {
    await _server.startServer();
    qrData.value = _server.qrPayload;
  }

  void stopDesktopServer() {
    _server.stopServer();
  }

  /// Called when mobile scans the QR code or enters IP
  Future<bool> connectAndSync(String ip, int port, String token) async {
    final ok = await _client.configure(ip, port, token);
    if (!ok) {
      isConnected.value = false;
      syncStatus.value = 'Could not reach server at $ip:$port';
      return false;
    }
    isConnected.value = true;
    return await _client.syncFromDesktop();
  }

  Future<bool> syncNow() async {
    if (!_client.isConnected.value && !isConnected.value) {
      syncStatus.value = 'Not connected. Scan QR code or enter PC IP first.';
      Get.snackbar('Not Connected', 'Please enter PC IP or scan QR code first',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return false;
    }
    isPulling.value = true;
    try {
      final success = await _client.syncFromDesktop();
      if (success) {
        Get.snackbar('Pull Complete', 'Downloaded latest catalog & data from Desktop PC',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Pull Failed', _client.syncStatus.value,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
      return success;
    } finally {
      isPulling.value = false;
    }
  }

  Future<bool> pushAllMobileDataToDesktop() async {
    final db = Get.find<AppDatabase>();
    isPushing.value = true;
    try {
      syncStatus.value = 'Preparing mobile data for push...';

      final invoices = await db.select(db.invoices).get();
      final purchases = await db.select(db.purchases).get();
      final customersList = await db.select(db.customers).get();

      final salesList = invoices.map((i) => {
        'id': i.id,
        'invoiceNumber': i.invoiceNumber,
        'customerId': i.customerId,
        'subtotal': i.subtotal,
        'taxTotal': i.taxTotal,
        'grandTotal': i.grandTotal,
        'paymentMethod': i.paymentMethod,
        'status': i.status,
        'createdAt': i.createdAt.toIso8601String(),
      }).toList();

      final purchasesList = purchases.map((p) => {
        'id': p.id,
        'purchaseNumber': p.purchaseNumber,
        'supplierId': p.supplierId,
        'grandTotal': p.grandTotal,
        'status': p.status,
        'purchaseDate': p.purchaseDate.toIso8601String(),
      }).toList();

      final customersData = customersList.map((c) => {
        'id': c.id,
        'name': c.name,
        'phone': c.phone,
        'email': c.email,
        'address': c.address,
        'gstNumber': c.gstNumber,
        'balanceDue': c.balanceDue,
        'creditLimit': c.creditLimit,
        'loyaltyPoints': c.loyaltyPoints,
        'createdAt': c.createdAt.toIso8601String(),
      }).toList();

      syncStatus.value = 'Pushing ${salesList.length} sales & ${customersData.length} customers to Desktop...';

      final success = await _client.pushToDesktop(
        salesList,
        purchasesList,
        customers: customersData,
      );
      if (success) {
        lastSyncTime.value = DateFormat('dd-MM-yyyy h:mm a').format(DateTime.now());
        syncStatus.value = '✅ Pushed ${salesList.length} sales & ${customersData.length} customers!';
        Get.snackbar(
          'Push Complete',
          'Uploaded ${salesList.length} sales & ${customersData.length} customers to PC',
          backgroundColor: Colors.green, colorText: Colors.white,
        );
        return true;
      } else {
        syncStatus.value = '❌ Push failed. Ensure Desktop app is open and Firewall port 8765 is allowed.';
        Get.snackbar('Push Failed', 'Could not reach PC server on port 8765',
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      syncStatus.value = '❌ Push error: $e';
      Get.snackbar('Error', 'Push error: $e', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isPushing.value = false;
    }
  }

  Future<bool> checkConnection() async {
    if (!isConnected.value) return false;
    return await _client.ping();
  }

  Future<bool> pushToDesktop(
    List<Map<String, dynamic>> sales,
    List<Map<String, dynamic>> purchases, {
    List<Map<String, dynamic>> customers = const [],
  }) async {
    return await _client.pushToDesktop(sales, purchases, customers: customers);
  }

  void startHost() {
    startDesktopServer();
  }

  void connectToHost(String ip) {
    _client.connectToServer(ip, 8765);
    isConnected.value = true;
  }
}
