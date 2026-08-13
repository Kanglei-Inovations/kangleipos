import 'dart:convert';
import 'package:drift/drift.dart' as d;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../database/database.dart';

class SyncClientService extends GetxService {
  final Logger _logger = Logger();
  final AppDatabase _db = Get.find<AppDatabase>();

  String? _serverIp;
  int _serverPort = 8765;
  String? _token;

  final RxBool isSyncing = false.obs;
  final RxBool isConnected = false.obs;
  final RxString syncStatus = ''.obs;
  final RxDouble syncProgress = 0.0.obs;
  final RxString lastSyncTime = 'Never'.obs;

  void configure(String ip, int port, String token) {
    _serverIp = ip;
    _serverPort = port;
    _token = token;
    isConnected.value = true;
  }

  String get baseUrl => 'http://$_serverIp:$_serverPort';

  Map<String, String> get _headers => {
    'X-Sync-Token': _token ?? '',
    'Content-Type': 'application/json',
  };

  /// Full sync: pull all data from desktop
  Future<bool> syncFromDesktop() async {
    if (_serverIp == null) {
      syncStatus.value = 'Not configured. Scan QR first.';
      return false;
    }
    isSyncing.value = true;
    syncProgress.value = 0.0;
    syncStatus.value = 'Connecting to desktop...';

    try {
      final resp = await http.get(
        Uri.parse('$baseUrl/sync/all'),
        headers: _headers,
      ).timeout(const Duration(seconds: 8));

      if (resp.statusCode != 200) {
        syncStatus.value = 'Server error: ${resp.statusCode}';
        return false;
      }

      syncStatus.value = 'Syncing data...';
      syncProgress.value = 0.1;

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      await _importAll(data);

      lastSyncTime.value = DateTime.now().toLocal().toString().substring(0, 16);
      syncStatus.value = '✅ Sync complete! Last: ${lastSyncTime.value}';
      syncProgress.value = 1.0;
      return true;
    } catch (e) {
      _logger.e('Sync failed: $e');
      syncStatus.value = '❌ Sync failed: $e';
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> _importAll(Map<String, dynamic> data) async {
    // Categories
    final cats = (data['categories'] as List?) ?? [];
    syncProgress.value = 0.15;
    for (final c in cats) {
      await _db.into(_db.categories).insertOnConflictUpdate(
        CategoriesCompanion.insert(id: c['id'], name: c['name']),
      );
    }

    // Brands
    final brands = (data['brands'] as List?) ?? [];
    syncProgress.value = 0.25;
    for (final b in brands) {
      await _db.into(_db.brands).insertOnConflictUpdate(
        BrandsCompanion.insert(id: b['id'], name: b['name']),
      );
    }

    // Products
    final products = (data['products'] as List?) ?? [];
    syncProgress.value = 0.35;
    for (final p in products) {
      await _db.into(_db.products).insertOnConflictUpdate(
        ProductsCompanion(
          id: d.Value(p['id']),
          name: d.Value(p['name']),
          barcode: d.Value(p['barcode'] ?? ''),
          sku: d.Value(p['sku'] ?? ''),
          price: d.Value((p['price'] as num).toDouble()),
          costPrice: d.Value((p['costPrice'] as num?)?.toDouble()),
          mrp: d.Value((p['mrp'] as num?)?.toDouble()),
          stockQuantity: d.Value((p['stockQuantity'] as num).toDouble()),
          unit: d.Value(p['unit'] ?? 'pcs'),
          gstRate: d.Value((p['gstRate'] as num?)?.toDouble() ?? 0.0),
          hsnSac: d.Value(p['hsnSac']),
          categoryId: d.Value(p['categoryId']),
          brandId: d.Value(p['brandId']),
        ),
      );
    }

    // Suppliers
    final suppliers = (data['suppliers'] as List?) ?? [];
    syncProgress.value = 0.55;
    for (final s in suppliers) {
      await _db.into(_db.suppliers).insertOnConflictUpdate(
        SuppliersCompanion(
          id: d.Value(s['id']),
          name: d.Value(s['name']),
          phone: d.Value(s['phone'] ?? ''),
          email: d.Value(s['email']),
          address: d.Value(s['address']),
          gstNumber: d.Value(s['gstNumber']),
          balanceDue: d.Value((s['balanceDue'] as num).toDouble()),
        ),
      );
    }

    // Customers
    final customers = (data['customers'] as List?) ?? [];
    syncProgress.value = 0.70;
    for (final c in customers) {
      await _db.into(_db.customers).insertOnConflictUpdate(
        CustomersCompanion(
          id: d.Value(c['id']),
          name: d.Value(c['name']),
          phone: d.Value(c['phone'] ?? ''),
          email: d.Value(c['email']),
          address: d.Value(c['address']),
          loyaltyPoints: d.Value((c['loyaltyPoints'] as num?)?.toDouble() ?? 0.0),
        ),
      );
    }

    // Purchases
    final purchases = (data['purchases'] as List?) ?? [];
    syncProgress.value = 0.85;
    for (final p in purchases) {
      await _db.into(_db.purchases).insertOnConflictUpdate(
        PurchasesCompanion.insert(
          id: p['id'],
          purchaseNumber: p['purchaseNumber'],
          supplierId: p['supplierId'],
          grandTotal: (p['grandTotal'] as num).toDouble(),
          status: d.Value(p['status'] ?? 'RECEIVED'),
        ),
      );
    }

    syncProgress.value = 1.0;
  }

  /// Push mobile-created sales/purchases back to desktop
  Future<bool> pushToDesktop(List<Map<String, dynamic>> sales, List<Map<String, dynamic>> purchases) async {
    if (_serverIp == null) return false;
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/sync/push'),
        headers: _headers,
        body: jsonEncode({'sales': sales, 'purchases': purchases}),
      ).timeout(const Duration(seconds: 15));
      return resp.statusCode == 200;
    } catch (e) {
      _logger.e('Push failed: $e');
      return false;
    }
  }

  Future<bool> ping() async {
    if (_serverIp == null) return false;
    try {
      final resp = await http.get(
        Uri.parse('$baseUrl/ping'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void connectToServer(String ip, int port) {
    // Legacy shim
    _serverIp = ip;
    _serverPort = port;
    isConnected.value = true;
  }
}
