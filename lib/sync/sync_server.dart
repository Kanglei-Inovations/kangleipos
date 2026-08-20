import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as d;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../modules/pos/controllers/pos_controller.dart';
import '../modules/customers/controllers/customer_controller.dart';
import '../modules/sales/controllers/sales_controller.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';

class SyncServerService extends GetxService {
  final Logger _logger = Logger();
  HttpServer? _server;
  final List<WebSocket> _wsClients = [];
  final RxBool isRunning = false.obs;
  final RxString serverToken = ''.obs;
  final RxString serverIp = ''.obs;
  final RxInt serverPort = 8765.obs;

  static const int _port = 8765;

  AppDatabase get _db => Get.find<AppDatabase>();

  final RxList<String> availableIps = <String>[].obs;

  Future<SyncServerService> init() async {
    await _detectIp();
    serverToken.value = const Uuid().v4().substring(0, 8).toUpperCase();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await startServer();
    }
    return this;
  }

  Future<void> _detectIp() async {
    availableIps.clear();
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (var iface in interfaces) {
        for (var addr in iface.addresses) {
          if (!addr.isLoopback && !addr.address.startsWith('127.')) {
            if (!availableIps.contains(addr.address)) {
              availableIps.add(addr.address);
            }
          }
        }
      }
    } catch (_) {}

    if (availableIps.isEmpty) {
      availableIps.add('127.0.0.1');
    }

    // Prioritize active non-virtual network interfaces over Windows Hotspot 192.168.137.x or APIPA
    availableIps.sort((a, b) {
      bool aIsVirtual = a.startsWith('192.168.137.') || a.startsWith('169.254.');
      bool bIsVirtual = b.startsWith('192.168.137.') || b.startsWith('169.254.');
      if (aIsVirtual && !bIsVirtual) return 1;
      if (!aIsVirtual && bIsVirtual) return -1;
      return 0;
    });

    serverIp.value = availableIps.first;
  }

  /// QR payload that mobile scans
  String get qrPayload {
    final ips = <String>{
      serverIp.value,
      ...availableIps,
      '127.0.0.1',
      'localhost',
      '10.0.2.2',
    }.toList();

    return jsonEncode({
      'ip': serverIp.value,
      'ips': ips,
      'port': _port,
      'token': serverToken.value,
    });
  }

  Future<void> startServer() async {
    if (isRunning.value) return;
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port, shared: true);
      isRunning.value = true;
      _logger.i('Sync Server started on ${serverIp.value}:$_port token=${serverToken.value}');

      _server!.listen(_handleRequest);
    } catch (e) {
      _logger.e('Failed to start Sync Server: $e');
    }
  }

  Future<void> _handleRequest(HttpRequest req) async {
    // CORS
    req.response.headers.add('Access-Control-Allow-Origin', '*');
    req.response.headers.add('Content-Type', 'application/json');

    final path = req.uri.path;
    final method = req.method;

    if (method == 'GET' && path == '/ping') {
      req.response.write(jsonEncode({'status': 'ok', 'time': DateTime.now().toIso8601String()}));
      await req.response.close();
      return;
    }

    final token = req.headers.value('X-Sync-Token') ?? '';
    if (token != serverToken.value) {
      req.response.statusCode = 401;
      req.response.write(jsonEncode({'error': 'Unauthorized'}));
      await req.response.close();
      return;
    }

    try {
      if (method == 'GET' && path == '/sync/all') {
        await _handleFullSync(req);
      } else if (method == 'POST' && path == '/sync/push') {
        await _handlePush(req);
      } else {
        req.response.statusCode = 404;
        req.response.write(jsonEncode({'error': 'Not found'}));
      }
    } catch (e) {
      req.response.statusCode = 500;
      req.response.write(jsonEncode({'error': e.toString()}));
    }
    await req.response.close();
  }

  Future<void> _handleFullSync(HttpRequest req) async {
    final products = await _db.select(_db.products).get();
    final suppliers = await _db.select(_db.suppliers).get();
    final customers = await _db.select(_db.customers).get();
    final purchases = await _db.select(_db.purchases).get();
    final categories = await _db.select(_db.categories).get();
    final brands = await _db.select(_db.brands).get();
    final invoices = await _db.select(_db.invoices).get();

    final payload = {
      'products': products.map((p) => _productToMap(p)).toList(),
      'suppliers': suppliers.map((s) => _supplierToMap(s)).toList(),
      'customers': customers.map((c) => _customerToMap(c)).toList(),
      'purchases': purchases.map((p) => _purchaseToMap(p)).toList(),
      'categories': categories.map((c) => {'id': c.id, 'name': c.name}).toList(),
      'brands': brands.map((b) => {'id': b.id, 'name': b.name}).toList(),
      'sales': invoices.map((i) => _invoiceToMap(i)).toList(),
      'syncedAt': DateTime.now().toIso8601String(),
    };

    req.response.write(jsonEncode(payload));
  }

  Future<void> _handlePush(HttpRequest req) async {
    final body = await utf8.decoder.bind(req).join();
    final data = jsonDecode(body) as Map<String, dynamic>;
    // Mobile pushed new purchases/sales → insert into desktop DB
    if (data['customers'] != null) {
      for (final c in (data['customers'] as List)) {
        try {
          await _db.into(_db.customers).insertOnConflictUpdate(
            CustomersCompanion(
              id: d.Value(c['id']),
              name: d.Value(c['name']),
              phone: d.Value(c['phone']),
              email: d.Value(c['email']),
              address: d.Value(c['address']),
              gstNumber: d.Value(c['gstNumber']),
              balanceDue: d.Value((c['balanceDue'] as num?)?.toDouble() ?? 0.0),
              creditLimit: d.Value((c['creditLimit'] as num?)?.toDouble() ?? 0.0),
              loyaltyPoints: d.Value((c['loyaltyPoints'] as num?)?.toDouble() ?? 0.0),
              createdAt: c['createdAt'] != null
                  ? d.Value(DateTime.parse(c['createdAt']))
                  : const d.Value.absent(),
            ),
          );
        } catch (_) {}
      }
    }
    if (data['purchases'] != null) {
      for (final p in (data['purchases'] as List)) {
        try {
          await _db.into(_db.purchases).insertOnConflictUpdate(
            PurchasesCompanion.insert(
              id: p['id'],
              purchaseNumber: p['purchaseNumber'],
              supplierId: p['supplierId'],
              grandTotal: (p['grandTotal'] as num).toDouble(),
              status: d.Value(p['status'] ?? 'RECEIVED'),
            ),
          );
        } catch (_) {}
      }
    }
    if (data['sales'] != null) {
      for (final s in (data['sales'] as List)) {
        try {
          await _db.into(_db.invoices).insertOnConflictUpdate(
            InvoicesCompanion.insert(
              id: s['id'],
              invoiceNumber: s['invoiceNumber'],
              customerId: d.Value(s['customerId']),
              subtotal: (s['subtotal'] as num?)?.toDouble() ?? (s['grandTotal'] as num).toDouble(),
              taxTotal: d.Value((s['taxTotal'] as num?)?.toDouble() ?? 0.0),
              grandTotal: (s['grandTotal'] as num).toDouble(),
              paymentMethod: d.Value(s['paymentMethod'] ?? 'CASH'),
              status: d.Value(s['status'] ?? 'PAID'),
              createdAt: s['createdAt'] != null ? d.Value(DateTime.parse(s['createdAt'])) : const d.Value.absent(),
            ),
          );
        } catch (_) {}
      }
    }

    // Refresh active controllers on PC so desktop UI updates in real-time
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<PosController>()) {
          Get.find<PosController>().refreshData();
        }
        if (Get.isRegistered<CustomerController>()) {
          Get.find<CustomerController>().refreshData();
        }
        if (Get.isRegistered<SalesController>()) {
          Get.find<SalesController>().refreshAllData();
        }
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().refreshDashboard();
        }
      });
    } catch (_) {}

    req.response.write(jsonEncode({'status': 'ok', 'received': DateTime.now().toIso8601String()}));
  }

  Map<String, dynamic> _productToMap(Product p) => {
    'id': p.id, 'name': p.name, 'barcode': p.barcode, 'sku': p.sku,
    'price': p.price, 'costPrice': p.costPrice, 'mrp': p.mrp,
    'stockQuantity': p.stockQuantity, 'unit': p.unit,
    'gstRate': p.gstRate, 'hsnSac': p.hsnSac,
    'categoryId': p.categoryId, 'brandId': p.brandId,
  };

  Map<String, dynamic> _supplierToMap(Supplier s) => {
    'id': s.id, 'name': s.name, 'phone': s.phone, 'email': s.email,
    'address': s.address, 'gstNumber': s.gstNumber, 'balanceDue': s.balanceDue,
  };

  Map<String, dynamic> _customerToMap(Customer c) => {
    'id': c.id, 'name': c.name, 'phone': c.phone, 'email': c.email,
    'address': c.address, 'gstNumber': c.gstNumber,
    'balanceDue': c.balanceDue, 'creditLimit': c.creditLimit,
    'loyaltyPoints': c.loyaltyPoints,
    'createdAt': c.createdAt.toIso8601String(),
  };

  Map<String, dynamic> _purchaseToMap(Purchase p) => {
    'id': p.id, 'purchaseNumber': p.purchaseNumber, 'supplierId': p.supplierId,
    'grandTotal': p.grandTotal, 'status': p.status,
    'purchaseDate': p.purchaseDate.toIso8601String(),
  };

  Map<String, dynamic> _invoiceToMap(Invoice i) => {
    'id': i.id, 'invoiceNumber': i.invoiceNumber,
    'customerId': i.customerId,
    'subtotal': i.subtotal, 'taxTotal': i.taxTotal,
    'grandTotal': i.grandTotal,
    'paymentMethod': i.paymentMethod,
    'status': i.status,
    'createdAt': i.createdAt.toIso8601String(),
  };

  void stopServer() {
    _server?.close(force: true);
    for (var ws in _wsClients) ws.close();
    _wsClients.clear();
    isRunning.value = false;
  }
}
