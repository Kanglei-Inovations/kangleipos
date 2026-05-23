import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../../../database/database.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class PurchaseItem {
  final Product product;
  double quantity;
  double costPrice;

  PurchaseItem({required this.product, this.quantity = 1, required this.costPrice});

  double get total => quantity * costPrice;
}

class PurchaseController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final _uuid = const Uuid();

  final RxList<PurchaseItem> items = <PurchaseItem>[].obs;
  final RxList<Supplier> suppliers = <Supplier>[].obs;
  final RxList<Product> products = <Product>[].obs;
  final RxList<Purchase> purchaseHistory = <Purchase>[].obs;
  final Rx<Supplier?> selectedSupplier = Rx<Supplier?>(null);
  
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedTab = 'All Purchases'.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final sList = await db.select(db.suppliers).get();
      final pList = await db.select(db.products).get();
      final hList = await db.select(db.purchases).get();
      
      suppliers.assignAll(sList);
      products.assignAll(pList);
      purchaseHistory.assignAll(hList);
    } finally {
      isLoading.value = false;
    }
  }

  // KPI GETTERS
  double get totalPurchases => purchaseHistory.fold(0.0, (sum, p) => sum + p.grandTotal);
  double get totalPaid => purchaseHistory.fold(0.0, (sum, p) => sum + (p.grandTotal * 0.8)); // Mocked logic
  double get totalDue => totalPurchases - totalPaid;
  int get totalInvoices => purchaseHistory.length;

  List<Purchase> get filteredPurchases {
    return purchaseHistory.where((p) {
      final matchesSearch = p.purchaseNumber.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  Map<String, double> get purchaseSummaryData {
    return {
      'Paid': totalPaid,
      'Partial': totalPurchases * 0.1,
      'Due': totalDue - (totalPurchases * 0.1),
    };
  }

  void addItem(Product product) {
    final existing = items.firstWhereOrNull((i) => i.product.id == product.id);
    if (existing != null) {
      existing.quantity++;
      items.refresh();
    } else {
      items.add(PurchaseItem(product: product, costPrice: product.costPrice ?? 0));
    }
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  Future<void> savePurchase() async {
    if (selectedSupplier.value == null || items.isEmpty) {
      Get.snackbar('Error', 'Please select a supplier and add items');
      return;
    }

    isLoading.value = true;
    try {
      final purchaseId = _uuid.v4();
      final purchaseNo = 'PUR-${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}';

      // 1. Save Purchase Record
      await db.into(db.purchases).insert(PurchasesCompanion(
        id: d.Value(purchaseId),
        purchaseNumber: d.Value(purchaseNo),
        supplierId: d.Value(selectedSupplier.value!.id),
        grandTotal: d.Value(totalAmount),
        status: const d.Value('RECEIVED'),
      ));

      // 2. Update Stock and Cost Prices
      for (var item in items) {
        final currentProduct = item.product;
        final newStock = currentProduct.stockQuantity + item.quantity;
        
        await (db.update(db.products)..where((t) => t.id.equals(currentProduct.id))).write(
          ProductsCompanion(
            stockQuantity: d.Value(newStock),
            costPrice: d.Value(item.costPrice), // Update cost price to last purchase price
          )
        );
      }

      // 3. Update Supplier Ledger (Increase Due if not paid immediately)
      // For now, we assume credit purchase as per standard ERP flow
      final newDue = selectedSupplier.value!.balanceDue + totalAmount;
      await (db.update(db.suppliers)..where((t) => t.id.equals(selectedSupplier.value!.id))).write(
        SuppliersCompanion(balanceDue: d.Value(newDue))
      );

      Get.snackbar('Success', 'Purchase $purchaseNo recorded and stock updated.');
      items.clear();
      selectedSupplier.value = null;
      await loadData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save purchase: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
