import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../../../database/database.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class PurchaseItem {
  Product? product;
  String productName;
  String barcode;
  String sku;
  String categoryId;
  String brandId;
  String unit;
  double quantity;
  double mrp;
  double costPrice;
  double sellingPrice;
  String discountType; // 'PERCENT' or 'FLAT'
  double discountValue;
  double gstRate; // 0, 5, 12, 18, 28
  String hsnCode;

  PurchaseItem({
    this.product,
    required this.productName,
    this.barcode = '',
    this.sku = '',
    this.categoryId = '',
    this.brandId = '',
    this.unit = 'pcs',
    this.quantity = 1.0,
    required this.mrp,
    required this.costPrice,
    required this.sellingPrice,
    this.discountType = 'FLAT',
    this.discountValue = 0.0,
    this.gstRate = 18.0,
    this.hsnCode = '',
  });

  double get grossAmount => quantity * costPrice;
  double get discountAmount {
    if (discountType == 'PERCENT') {
      return grossAmount * (discountValue / 100);
    }
    return quantity * discountValue;
  }

  double get taxableAmount => (grossAmount - discountAmount).clamp(0.0, double.infinity);
  double get taxAmount => taxableAmount * (gstRate / 100);
  double get cgstAmount => taxAmount / 2;
  double get sgstAmount => taxAmount / 2;
  double get totalItemAmount => taxableAmount + taxAmount;
}

class PurchaseController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final _uuid = const Uuid();

  final RxList<PurchaseItem> items = <PurchaseItem>[].obs;
  final RxList<Supplier> suppliers = <Supplier>[].obs;
  final RxList<Product> products = <Product>[].obs;
  final RxList<Purchase> purchaseHistory = <Purchase>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Brand> brands = <Brand>[].obs;

  final Rx<Supplier?> selectedSupplier = Rx<Supplier?>(null);
  final RxString supplierInvoiceNumber = ''.obs;
  final RxDouble paidAmount = 0.0.obs;
  final RxString paymentMethod = 'CASH'.obs;
  final RxBool isInterStateGst = false.obs;

  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedTab = 'All Purchases'.obs;
  final RxString selectedStatusFilter = 'All Status'.obs;
  final Rx<Supplier?> selectedSupplierFilter = Rx<Supplier?>(null);

  final RxInt currentPage = 1.obs;
  final RxInt rowsPerPage = 5.obs;

  int get totalPages => (filteredPurchases.isEmpty)
      ? 1
      : (filteredPurchases.length / rowsPerPage.value).ceil();

  List<Purchase> get paginatedPurchases {
    final start = (currentPage.value - 1) * rowsPerPage.value;
    if (start >= filteredPurchases.length) return [];
    final end = start + rowsPerPage.value;
    return filteredPurchases.sublist(
      start,
      end > filteredPurchases.length ? filteredPurchases.length : end,
    );
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void setRowsPerPage(int count) {
    rowsPerPage.value = count;
    currentPage.value = 1;
  }

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
      final cList = await db.select(db.categories).get();
      final bList = await db.select(db.brands).get();
      
      suppliers.assignAll(sList);
      products.assignAll(pList);
      purchaseHistory.assignAll(hList);
      categories.assignAll(cList);
      brands.assignAll(bList);
    } finally {
      isLoading.value = false;
    }
  }

  // KPI GETTERS
  double get totalPurchases => purchaseHistory.fold(0.0, (sum, p) => sum + p.grandTotal);
  double get totalPaid => purchaseHistory.fold(0.0, (sum, p) => sum + (p.grandTotal * 0.8));
  double get totalDue => totalPurchases - totalPaid;
  int get totalInvoices => purchaseHistory.length;

  // TAX & FINANCIAL BREAKDOWN GETTERS
  double get subtotalGrossAmount => items.fold(0.0, (sum, i) => sum + i.grossAmount);
  double get totalDiscountAmount => items.fold(0.0, (sum, i) => sum + i.discountAmount);
  double get totalTaxableAmount => items.fold(0.0, (sum, i) => sum + i.taxableAmount);
  double get totalTaxAmount => items.fold(0.0, (sum, i) => sum + i.taxAmount);
  double get totalCgstAmount => totalTaxAmount / 2;
  double get totalSgstAmount => totalTaxAmount / 2;
  double get grandTotalAmount => totalTaxableAmount + totalTaxAmount;
  double get calculatedDue => (grandTotalAmount - paidAmount.value).clamp(0.0, double.infinity);

  List<Purchase> get filteredPurchases {
    return purchaseHistory.where((p) {
      final supplier = suppliers.firstWhereOrNull((s) => s.id == p.supplierId);
      final query = searchQuery.value.toLowerCase();
      final matchesSearch = p.purchaseNumber.toLowerCase().contains(query) ||
          (supplier?.name.toLowerCase().contains(query) ?? false);

      final tab = selectedTab.value;
      bool matchesTab = true;
      if (tab == 'Purchase Orders') {
        matchesTab = p.status == 'ORDER' || p.status == 'PENDING';
      } else if (tab == 'GRN / Receive Notes') {
        matchesTab = p.status == 'RECEIVED' || p.status == 'GRN';
      } else if (tab == 'Returns') {
        matchesTab = p.status == 'RETURNED' || p.status == 'DEBIT_NOTE';
      } else if (tab == 'Bills') {
        matchesTab = p.status == 'RECEIVED' || p.status == 'PAID' || p.status == 'PARTIAL' || p.status == 'DUE';
      }

      final status = selectedStatusFilter.value;
      bool matchesStatus = true;
      if (status != 'All Status') {
        matchesStatus = p.status.toLowerCase() == status.toLowerCase();
      }

      bool matchesSupplier = true;
      if (selectedSupplierFilter.value != null) {
        matchesSupplier = p.supplierId == selectedSupplierFilter.value!.id;
      }

      return matchesSearch && matchesTab && matchesStatus && matchesSupplier;
    }).toList();
  }

  Map<String, double> get purchaseSummaryData {
    return {
      'Paid': totalPaid,
      'Partial': totalPurchases * 0.1,
      'Due': totalDue - (totalPurchases * 0.1),
    };
  }

  void addItem(PurchaseItem item) {
    final existingIndex = items.indexWhere((i) =>
        (item.product != null && i.product?.id == item.product?.id) ||
        (i.productName.toLowerCase() == item.productName.toLowerCase() && i.productName.isNotEmpty));

    if (existingIndex >= 0) {
      items[existingIndex].quantity += item.quantity;
      items.refresh();
    } else {
      items.add(item);
    }
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  Future<void> savePurchase({String type = 'BILL'}) async {
    if (selectedSupplier.value == null || items.isEmpty) {
      Get.snackbar('Error', 'Please select a supplier and add at least one item');
      return;
    }

    isLoading.value = true;
    try {
      final purchaseId = _uuid.v4();
      final sysNo = 'PUR-${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}';
      final pNo = supplierInvoiceNumber.value.isNotEmpty ? supplierInvoiceNumber.value : sysNo;

      final total = grandTotalAmount;
      final paid = paidAmount.value;
      final due = total - paid;
      final pStatus = due <= 0 ? 'PAID' : (paid > 0 ? 'PARTIAL' : 'DUE');

      // 1. Process Product Catalog & Inventory Crediting
      for (var item in items) {
        if (item.product != null) {
          // Update existing product in catalog
          final currentProduct = item.product!;
          final newStock = currentProduct.stockQuantity + item.quantity;

          await (db.update(db.products)..where((t) => t.id.equals(currentProduct.id))).write(
            ProductsCompanion(
              stockQuantity: d.Value(newStock),
              costPrice: d.Value(item.costPrice),
              price: d.Value(item.sellingPrice),
              mrp: d.Value(item.mrp),
              gstRate: d.Value(item.gstRate),
              hsnSac: d.Value(item.hsnCode),
            ),
          );
        } else {
          // Create new product in catalog
          final newProdId = _uuid.v4();
          await db.into(db.products).insert(ProductsCompanion(
            id: d.Value(newProdId),
            name: d.Value(item.productName),
            barcode: d.Value(item.barcode.isNotEmpty ? item.barcode : newProdId.substring(0, 8)),
            sku: d.Value(item.sku.isNotEmpty ? item.sku : 'SKU-${newProdId.substring(0, 6).toUpperCase()}'),
            categoryId: item.categoryId.isNotEmpty ? d.Value(item.categoryId) : const d.Value.absent(),
            brandId: item.brandId.isNotEmpty ? d.Value(item.brandId) : const d.Value.absent(),
            unit: d.Value(item.unit.isNotEmpty ? item.unit : 'pcs'),
            price: d.Value(item.sellingPrice),
            mrp: d.Value(item.mrp),
            costPrice: d.Value(item.costPrice),
            gstRate: d.Value(item.gstRate),
            hsnSac: d.Value(item.hsnCode),
            stockQuantity: d.Value(item.quantity), // Credited directly from purchase
          ));
        }
      }

      // 2. Save Purchase Record
      await db.into(db.purchases).insert(PurchasesCompanion(
        id: d.Value(purchaseId),
        purchaseNumber: d.Value(pNo),
        supplierId: d.Value(selectedSupplier.value!.id),
        grandTotal: d.Value(total),
        status: d.Value(pStatus),
      ));

      // 3. Update Supplier Ledger Balance
      if (due > 0) {
        final newDue = selectedSupplier.value!.balanceDue + due;
        await (db.update(db.suppliers)..where((t) => t.id.equals(selectedSupplier.value!.id))).write(
          SuppliersCompanion(balanceDue: d.Value(newDue)),
        );
      }

      Get.snackbar('Purchase Entry Saved',
          'Vendor Bill #$pNo saved successfully! Stock & Supplier Ledger updated.');

      items.clear();
      supplierInvoiceNumber.value = '';
      paidAmount.value = 0.0;
      selectedSupplier.value = null;
      await loadData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save purchase: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Category?> addNewCategoryInline(String categoryName) async {
    try {
      final catId = _uuid.v4();
      await db.into(db.categories).insert(CategoriesCompanion(
        id: d.Value(catId),
        name: d.Value(categoryName),
      ));
      await loadData();
      return categories.firstWhereOrNull((c) => c.id == catId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add category: $e');
      return null;
    }
  }

  Future<Brand?> addNewBrandInline(String brandName) async {
    try {
      final brandId = _uuid.v4();
      await db.into(db.brands).insert(BrandsCompanion(
        id: d.Value(brandId),
        name: d.Value(brandName),
      ));
      await loadData();
      return brands.firstWhereOrNull((b) => b.id == brandId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add brand: $e');
      return null;
    }
  }

  Future<Supplier?> addNewSupplierInline(String supplierName, String phone) async {
    try {
      final sId = _uuid.v4();
      await db.into(db.suppliers).insert(SuppliersCompanion(
        id: d.Value(sId),
        name: d.Value(supplierName),
        phone: d.Value(phone),
      ));
      await loadData();
      final newS = suppliers.firstWhereOrNull((s) => s.id == sId);
      if (newS != null) selectedSupplier.value = newS;
      return newS;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add supplier: $e');
      return null;
    }
  }

  Future<void> createPurchaseReturn(Purchase purchase, Product product, double qty) async {
    isLoading.value = true;
    try {
      final newStock = (product.stockQuantity - qty).clamp(0.0, double.infinity);
      await (db.update(db.products)..where((t) => t.id.equals(product.id))).write(
        ProductsCompanion(stockQuantity: d.Value(newStock))
      );

      final supplier = suppliers.firstWhereOrNull((s) => s.id == purchase.supplierId);
      if (supplier != null) {
        final returnVal = qty * (product.costPrice ?? 0.0);
        final newDue = (supplier.balanceDue - returnVal).clamp(0.0, double.infinity);
        await (db.update(db.suppliers)..where((t) => t.id.equals(supplier.id))).write(
          SuppliersCompanion(balanceDue: d.Value(newDue))
        );
      }

      Get.snackbar('Purchase Return Logged', 'Returned $qty x ${product.name}. Stock & Vendor Ledger updated.');
      await loadData();
    } finally {
      isLoading.value = false;
    }
  }
}
