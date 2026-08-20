import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../../../database/database.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../services/pdf_service.dart';
import '../../../sync/sync_client.dart';
import '../../customers/controllers/customer_controller.dart';
import '../models/cart_item.dart';

class PosController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final _uuid = const Uuid();

  // State
  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Customer> customers = <Customer>[].obs;
  
  final RxList<CartItem> cart = <CartItem>[].obs;
  final Rx<Customer?> selectedCustomer = Rx<Customer?>(null);
  
  final RxString selectedCategoryId = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  // Pagination & Filtering
  final RxInt currentPage = 1.obs;
  final RxInt rowsPerPage = 12.obs;
  final RxInt totalPages = 1.obs;
  final RxString selectedBrandId = 'All'.obs;
  final Rx<RangeValues> priceRange = const RangeValues(0, 100000).obs;

  // UI State for Redesign
  final RxInt currentInvoiceTab = 0.obs;
  final RxString selectedPaymentMethod = 'Cash'.obs;
  final RxDouble receivedAmount = 0.0.obs;
  final RxInt holdCount = 0.obs; 
  final RxInt draftCount = 0.obs;

  // Split Payment: individual amounts for each method
  final RxMap<String, double> splitAmounts = <String, double>{
    'Cash': 0.0,
    'UPI': 0.0,
    'Due': 0.0,
    'Payment Gateway': 0.0,
  }.obs;

  // Persistent Hold Data
  final RxList<Invoice> heldInvoicesList = <Invoice>[].obs;
  final RxList<Invoice> invoicesList = <Invoice>[].obs;
  final RxMap<String, List<InvoiceItem>> heldItemsMap = <String, List<InvoiceItem>>{}.obs;
  final Rx<Invoice?> selectedHeldInvoice = Rx<Invoice?>(null);

  @override
  void onInit() {
    super.onInit();
    refreshData();
    _fetchHeldInvoices();
  }

  Future<void> _fetchHeldInvoices() async {
    final list = await (db.select(db.invoices)..where((t) => t.status.equals('HOLD'))).get();
    
    // Fetch items for all held invoices to show counts/qty
    final Map<String, List<InvoiceItem>> tempMap = {};
    for (var inv in list) {
      final items = await (db.select(db.invoiceItems)..where((t) => t.invoiceId.equals(inv.id))).get();
      tempMap[inv.id] = items;
    }
    
    heldItemsMap.assignAll(tempMap);
    heldInvoicesList.assignAll(list);
    holdCount.value = heldInvoicesList.length;
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      final pList = await db.select(db.products).get();
      final cList = await db.select(db.categories).get();
      final custList = await db.select(db.customers).get();
      final invList = await (db.select(db.invoices)..orderBy([(t) => d.OrderingTerm.desc(t.createdAt)])).get();
      
      products.assignAll(pList);
      categories.assignAll(cList);
      customers.assignAll(custList);
      invoicesList.assignAll(invList);

      _updatePagination();
    } finally {
      isLoading.value = false;
    }
  }

  void _updatePagination() {
    final count = filteredProducts.length;
    totalPages.value = (count / rowsPerPage.value).ceil();
    if (totalPages.value == 0) totalPages.value = 1;
    if (currentPage.value > totalPages.value) currentPage.value = totalPages.value;
  }

  List<Product> get filteredProducts {
    return products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                           (p.barcode?.contains(searchQuery.value) ?? false) ||
                           (p.sku?.contains(searchQuery.value) ?? false);
      final matchesCategory = selectedCategoryId.value == 'All' || p.categoryId == selectedCategoryId.value;
      final matchesBrand = selectedBrandId.value == 'All' || p.brandId == selectedBrandId.value;
      final matchesPrice = p.price >= priceRange.value.start && p.price <= priceRange.value.end;

      return matchesSearch && matchesCategory && matchesBrand && matchesPrice;
    }).toList();
  }

  List<Product> get paginatedProducts {
    final start = (currentPage.value - 1) * rowsPerPage.value;
    final filtered = filteredProducts;
    if (start >= filtered.length) return [];
    final end = (start + rowsPerPage.value).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  void changePage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
    }
  }

  void addToCart(Product product) {
    final existingIndex = cart.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      cart[existingIndex].quantity++;
      cart.refresh();
    } else {
      cart.add(CartItem(product: product));
    }
  }

  void updateQuantity(String productId, int delta) {
    final index = cart.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      cart[index].quantity += delta;
      if (cart[index].quantity <= 0) {
        cart.removeAt(index);
      } else {
        cart.refresh();
      }
    }
  }

  void clearCart() {
    cart.clear();
    selectedCustomer.value = null;
    receivedAmount.value = 0.0;
    splitAmounts.updateAll((key, value) => 0.0);
    selectedPaymentMethod.value = 'Cash';
  }

  // Add Customer from POS
  Future<Customer> addNewCustomer({
    required String name,
    String? phone,
    String? address,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final newCust = Customer(
      id: id,
      name: name,
      phone: phone,
      address: address,
      balanceDue: 0.0,
      creditLimit: 0.0,
      loyaltyPoints: 0.0,
      createdAt: now,
    );

    await db.into(db.customers).insert(CustomersCompanion(
      id: d.Value(id),
      name: d.Value(name),
      phone: d.Value(phone),
      address: d.Value(address),
      balanceDue: const d.Value(0.0),
    ));

    // Refresh customers list in POS
    final custList = await db.select(db.customers).get();
    customers.assignAll(custList);

    // Refresh CustomerController if registered
    try {
      if (Get.isRegistered<CustomerController>()) {
        Get.find<CustomerController>().refreshData();
      }
    } catch (_) {}

    selectedCustomer.value = newCust;

    // Push the new customer to desktop PC immediately
    _pushCustomerToDesktop(newCust);

    return newCust;
  }

  void _pushCustomerToDesktop(Customer cust) async {
    try {
      if (!Get.isRegistered<SyncClientService>()) return;
      final client = Get.find<SyncClientService>();
      if (!client.isConnected.value) return;

      await client.pushToDesktop([], [], customers: [
        {
          'id': cust.id,
          'name': cust.name,
          'phone': cust.phone,
          'email': cust.email,
          'address': cust.address,
          'gstNumber': cust.gstNumber,
          'balanceDue': cust.balanceDue,
          'creditLimit': cust.creditLimit,
          'loyaltyPoints': cust.loyaltyPoints,
          'createdAt': cust.createdAt.toIso8601String(),
        }
      ]);
    } catch (_) {}
  }


  // CALCULATIONS
  double get subtotal => cart.fold(0, (sum, item) => sum + item.subtotal);
  double get totalGst => cart.fold(0, (sum, item) => sum + item.gstAmount);
  double get cgst => totalGst / 2;
  double get sgst => totalGst / 2;
  double get discount => 0.0;
  double get grandTotal => subtotal + totalGst - discount;

  // Checkout Logic
  Future<void> processCheckout(String paymentMethod) async {
    if (cart.isEmpty) return;

    final total = grandTotal;

    // For Split: sum all split input amounts as the received amount
    double rec;
    if (paymentMethod == 'Split') {
      rec = splitAmounts.values.fold(0.0, (a, b) => a + b);
      // Due portion in split is the split Due field
    } else if (paymentMethod == 'Due') {
      // Selecting Due = customer takes full credit
      rec = 0.0;
    } else {
      rec = receivedAmount.value;
    }

    final dueAmount = math.max(0.0, total - rec);

    String status;
    if (paymentMethod == 'Due') {
      status = 'UNPAID';
    } else if (rec <= 0) {
      status = 'UNPAID';
    } else if (rec < total) {
      status = 'PARTIAL';
    } else {
      status = 'PAID';
    }

    // Validation: require customer for any due amount
    if (dueAmount > 0 && selectedCustomer.value == null) {
      Get.snackbar(
        'Customer Required for Due Sale',
        'Amount ₹${dueAmount.toStringAsFixed(2)} is remaining as DUE. Please select or add a customer to record due/credit sales.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    isLoading.value = true;
    try {
      final invoiceId = _uuid.v4();
      final invoiceNumber = 'INV-${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}';

      // 1. Create Invoice Entry with real status & payment method
      await db.into(db.invoices).insert(InvoicesCompanion(
        id: d.Value(invoiceId),
        invoiceNumber: d.Value(invoiceNumber),
        customerId: d.Value(selectedCustomer.value?.id),
        subtotal: d.Value(subtotal),
        taxTotal: d.Value(totalGst),
        grandTotal: d.Value(total),
        paymentMethod: d.Value(paymentMethod),
        status: d.Value(status),
        createdAt: d.Value(DateTime.now()),
      ));

      // 2. Create Invoice Items & Update Stock
      for (var item in cart) {
        await db.into(db.invoiceItems).insert(InvoiceItemsCompanion(
          id: d.Value(_uuid.v4()),
          invoiceId: d.Value(invoiceId),
          productId: d.Value(item.product.id),
          productName: d.Value(item.product.name),
          quantity: d.Value(item.quantity.toDouble()),
          unitPrice: d.Value(item.product.price),
          subtotal: d.Value(item.subtotal),
          gstRate: d.Value(item.product.gstRate),
          gstAmount: d.Value(item.gstAmount),
          total: d.Value(item.total),
        ));

        // Deduct stock
        final updatedStock = item.product.stockQuantity - item.quantity;
        await (db.update(db.products)..where((t) => t.id.equals(item.product.id)))
            .write(ProductsCompanion(stockQuantity: d.Value(updatedStock)));
      }

      // 3. Update Customer Balance Due if dueAmount > 0
      if (dueAmount > 0 && selectedCustomer.value != null) {
        final cust = selectedCustomer.value!;
        final newDue = cust.balanceDue + dueAmount;
        await (db.update(db.customers)..where((t) => t.id.equals(cust.id)))
            .write(CustomersCompanion(balanceDue: d.Value(newDue)));
      }

      final statusMsg = status == 'PAID'
          ? 'Paid in Full'
          : status == 'PARTIAL'
              ? 'Partial Paid (Due: ₹${dueAmount.toStringAsFixed(2)})'
              : 'DUE Sale (Due: ₹${dueAmount.toStringAsFixed(2)})';

      Get.snackbar('Success', 'Invoice $invoiceNumber ($statusMsg) generated successfully!',
          backgroundColor: status == 'PAID' ? Colors.green : Colors.orange,
          colorText: Colors.white);

      // Open PDF Preview
      await PdfService.generateAndPrintInvoice(
        invoiceNumber: invoiceNumber,
        customer: selectedCustomer.value,
        items: List.from(cart),
        subtotal: subtotal,
        taxTotal: totalGst,
        grandTotal: total,
      );

      // Auto-Sync sale to Desktop Server in background if connected
      _autoPushSaleToDesktop(invoiceId, invoiceNumber, subtotal, totalGst, total, paymentMethod, status);

      clearCart();
      await refreshData(); // Refresh product list & customer list for stock/due updates
    } catch (e) {
      Get.snackbar('Error', 'Checkout failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _autoPushSaleToDesktop(String invoiceId, String invoiceNumber, double sub, double tax, double total, String method, String status) async {
    try {
      if (!Get.isRegistered<SyncClientService>()) return;
      final client = Get.find<SyncClientService>();
      if (!client.isConnected.value) return;

      final saleData = {
        'id': invoiceId,
        'invoiceNumber': invoiceNumber,
        'customerId': selectedCustomer.value?.id,
        'subtotal': sub,
        'taxTotal': tax,
        'grandTotal': total,
        'paymentMethod': method,
        'status': status,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Also push the customer if one is linked, so PC gets new customers immediately
      final List<Map<String, dynamic>> customerPayload = [];
      final cust = selectedCustomer.value;
      if (cust != null) {
        customerPayload.add({
          'id': cust.id,
          'name': cust.name,
          'phone': cust.phone,
          'email': cust.email,
          'address': cust.address,
          'gstNumber': cust.gstNumber,
          'balanceDue': cust.balanceDue,
          'creditLimit': cust.creditLimit,
          'loyaltyPoints': cust.loyaltyPoints,
          'createdAt': cust.createdAt.toIso8601String(),
        });
      }

      final success = await client.pushToDesktop([saleData], [], customers: customerPayload);
      if (success) {
        client.syncFromDesktop();
      }
    } catch (_) {}
  }

  // --- HOLD INVOICE LOGIC ---
  Future<void> holdCurrentInvoice() async {
    if (cart.isEmpty) {
      Get.snackbar('Empty Cart', 'Please add items before holding an invoice', 
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      final invoiceId = _uuid.v4();
      final invoiceNumber = 'HLD-${DateTime.now().millisecondsSinceEpoch}';

      // 1. Save Hold Invoice Header
      await db.into(db.invoices).insert(InvoicesCompanion(
        id: d.Value(invoiceId),
        invoiceNumber: d.Value(invoiceNumber),
        customerId: d.Value(selectedCustomer.value?.id),
        subtotal: d.Value(subtotal),
        taxTotal: d.Value(totalGst),
        grandTotal: d.Value(grandTotal),
        status: d.Value('HOLD'),
        createdAt: d.Value(DateTime.now()),
      ));

      // 2. Save Hold Invoice Items
      for (var item in cart) {
        await db.into(db.invoiceItems).insert(InvoiceItemsCompanion(
          id: d.Value(_uuid.v4()),
          invoiceId: d.Value(invoiceId),
          productId: d.Value(item.product.id),
          productName: d.Value(item.product.name),
          quantity: d.Value(item.quantity.toDouble()),
          unitPrice: d.Value(item.product.price),
          subtotal: d.Value(item.subtotal),
          gstRate: d.Value(item.product.gstRate),
          gstAmount: d.Value(item.gstAmount),
          total: d.Value(item.total),
        ));
      }

      clearCart();
      await _fetchHeldInvoices();
      currentInvoiceTab.value = 1;

      Get.snackbar('Invoice Held', 'Invoice #$invoiceNumber saved successfully', 
        backgroundColor: Colors.blue, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to hold invoice: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> resumeHoldInvoice(Invoice? invoice) async {
    final target = invoice ?? selectedHeldInvoice.value;
    if (target == null) return;

    try {
      // 1. Fetch Items
      final items = await (db.select(db.invoiceItems)..where((t) => t.invoiceId.equals(target.id))).get();
      
      // 2. Clear current cart and load items
      clearCart();
      for (var itemRecord in items) {
        final product = products.firstWhere((p) => p.id == itemRecord.productId);
        cart.add(CartItem(product: product, quantity: itemRecord.quantity.toInt()));
      }

      // 3. Set Customer if available
      if (target.customerId != null) {
        selectedCustomer.value = customers.firstWhereOrNull((c) => c.id == target.customerId);
      }

      // 4. Delete the Hold Record from DB
      await (db.delete(db.invoiceItems)..where((t) => t.invoiceId.equals(target.id))).go();
      await (db.delete(db.invoices)..where((t) => t.id.equals(target.id))).go();

      await _fetchHeldInvoices();
      selectedHeldInvoice.value = null;
      currentInvoiceTab.value = 0; // Back to main POS

      Get.snackbar('Resumed', 'Invoice #${target.invoiceNumber} is now active', 
        backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to resume invoice: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> deleteHoldInvoice(Invoice? invoice) async {
    final target = invoice ?? selectedHeldInvoice.value;
    if (target == null) return;

    try {
      await (db.delete(db.invoiceItems)..where((t) => t.invoiceId.equals(target.id))).go();
      await (db.delete(db.invoices)..where((t) => t.id.equals(target.id))).go();
      
      await _fetchHeldInvoices();
      if (selectedHeldInvoice.value?.id == target.id) selectedHeldInvoice.value = null;

      Get.snackbar('Deleted', 'Hold invoice removed successfully', 
        backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete hold invoice: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> clearAllHolds() async {
    try {
      final holdIds = heldInvoicesList.map((e) => e.id).toList();
      await (db.delete(db.invoiceItems)..where((t) => t.invoiceId.isIn(holdIds))).go();
      await (db.delete(db.invoices)..where((t) => t.status.equals('HOLD'))).go();
      
      await _fetchHeldInvoices();
      selectedHeldInvoice.value = null;

      Get.snackbar('Cleared', 'All hold invoices have been removed', 
        backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear holds: $e', backgroundColor: Colors.red);
    }
  }
}
