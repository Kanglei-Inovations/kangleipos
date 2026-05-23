import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../../../database/database.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../services/pdf_service.dart';
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
  final RxInt rowsPerPage = 20.obs;
  final RxInt totalPages = 1.obs;
  final RxString selectedBrandId = 'All'.obs;
  final Rx<RangeValues> priceRange = const RangeValues(0, 100000).obs;

  // UI State for Redesign
  final RxInt currentInvoiceTab = 0.obs;
  final RxString selectedPaymentMethod = 'Cash'.obs;
  final RxDouble receivedAmount = 0.0.obs;
  final RxInt holdCount = 0.obs; 
  final RxInt draftCount = 0.obs;

  // Persistent Hold Data
  final RxList<Invoice> heldInvoicesList = <Invoice>[].obs;
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
      
      products.assignAll(pList);
      categories.assignAll(cList);
      customers.assignAll(custList);

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
  }

  // CALCULATIONS
  double get subtotal => cart.fold(0, (sum, item) => sum + item.subtotal);
  double get totalGst => cart.fold(0, (sum, item) => sum + item.gstAmount);
  double get grandTotal => subtotal + totalGst;

  // Checkout Logic
  Future<void> processCheckout(String paymentMethod) async {
    if (cart.isEmpty) return;

    isLoading.value = true;
    try {
      final invoiceId = _uuid.v4();
      final invoiceNumber = 'INV-${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}';

      // 1. Create Invoice Entry
      await db.into(db.invoices).insert(InvoicesCompanion(
        id: d.Value(invoiceId),
        invoiceNumber: d.Value(invoiceNumber),
        customerId: d.Value(selectedCustomer.value?.id),
        subtotal: d.Value(subtotal),
        taxTotal: d.Value(totalGst),
        grandTotal: d.Value(grandTotal),
        paymentMethod: d.Value(paymentMethod),
        status: d.Value('PAID'),
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

      Get.snackbar('Success', 'Invoice $invoiceNumber generated successfully!',
          backgroundColor: Get.theme.primaryColor, colorText: Colors.white);
      
      // Open PDF Preview
      await PdfService.generateAndPrintInvoice(
        invoiceNumber: invoiceNumber,
        customer: selectedCustomer.value,
        items: List.from(cart),
        subtotal: subtotal,
        taxTotal: totalGst,
        grandTotal: grandTotal,
      );
      
      clearCart();
      await refreshData(); // Refresh product list for stock updates
    } catch (e) {
      Get.snackbar('Error', 'Checkout failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
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
