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

  @override
  void onInit() {
    super.onInit();
    refreshData();
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
    } finally {
      isLoading.value = false;
    }
  }

  List<Product> get filteredProducts {
    return products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                           (p.barcode?.contains(searchQuery.value) ?? false);
      final matchesCategory = selectedCategoryId.value == 'All' || p.categoryId == selectedCategoryId.value;
      return matchesSearch && matchesCategory;
    }).toList();
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
}
