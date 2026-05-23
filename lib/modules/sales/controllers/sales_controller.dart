import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';

class SalesController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  
  final RxList<Invoice> sales = <Invoice>[].obs;
  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  
  // Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedPaymentMethod = 'All Payment'.obs;
  final RxString selectedDateRange = 'All Time'.obs;
  final RxString selectedStatus = 'All Status'.obs;
  final RxString selectedCustomerId = 'All Customers'.obs;
  
  // Stats
  final RxMap<String, double> categorySales = <String, double>{}.obs;
  final RxDouble totalSalesAmount = 0.0.obs;
  final RxDouble totalProfitAmount = 0.0.obs;
  final RxInt totalOrdersCount = 0.obs;
  final RxMap<String, double> topCustomers = <String, double>{}.obs;
  final RxDouble totalReturnsAmount = 0.0.obs;
  final RxInt totalReturnOrdersCount = 0.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt rowsPerPage = 10.obs;

  @override
  void onInit() {
    super.onInit();
    refreshAllData();
  }

  Future<void> refreshAllData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        refreshSales(),
        refreshCustomers(),
        calculateCategoryStats(),
        calculateSummaryStats(),
        calculateTopCustomers(),
        calculateReturnStats(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshSales() async {
    final list = await db.select(db.invoices).get();
    sales.assignAll(list.reversed.toList());
  }

  Future<void> refreshCustomers() async {
    final list = await db.select(db.customers).get();
    customers.assignAll(list);
  }

  Future<void> calculateCategoryStats() async {
    final items = await db.select(db.invoiceItems).get();
    final Map<String, double> stats = {};
    for (var item in items) {
      final cat = 'General'; 
      stats[cat] = (stats[cat] ?? 0.0) + item.total;
    }
    categorySales.assignAll(stats);
  }

  Future<void> calculateSummaryStats() async {
    double total = 0;
    for (var s in sales) {
      total += s.grandTotal;
    }
    totalSalesAmount.value = total;
    totalOrdersCount.value = sales.length;
    totalProfitAmount.value = total * 0.25; 
  }

  Future<void> calculateTopCustomers() async {
    final Map<String, double> custStats = {};
    for (var s in sales) {
      final name = s.customerId ?? 'Walk-in';
      custStats[name] = (custStats[name] ?? 0.0) + s.grandTotal;
    }
    final sortedEntries = custStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    topCustomers.assignAll(Map.fromEntries(sortedEntries.take(5)));
  }

  Future<void> calculateReturnStats() async {
    final returns = await (db.select(db.invoices)..where((t) => t.status.equals('RETURNED'))).get();
    totalReturnsAmount.value = returns.fold(0.0, (sum, item) => sum + item.grandTotal);
    totalReturnOrdersCount.value = returns.length;
  }

  void updateSearch(String val) {
    searchQuery.value = val;
    currentPage.value = 1;
  }

  void updatePaymentFilter(String val) {
    selectedPaymentMethod.value = val;
    currentPage.value = 1;
  }

  void updateDateFilter(String val) {
    selectedDateRange.value = val;
    currentPage.value = 1;
  }

  void updateStatusFilter(String val) {
    selectedStatus.value = val;
    currentPage.value = 1;
  }

  void updateCustomerFilter(String val) {
    selectedCustomerId.value = val;
    currentPage.value = 1;
  }

  List<Invoice> get filteredSales {
    Iterable<Invoice> filtered = sales;
    
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      filtered = filtered.where((s) => 
        s.invoiceNumber.toLowerCase().contains(q) || 
        (s.customerId?.toLowerCase().contains(q) ?? false)
      );
    }
    
    if (selectedPaymentMethod.value != 'All Payment') {
      filtered = filtered.where((s) => s.paymentMethod.toUpperCase() == selectedPaymentMethod.value.toUpperCase());
    }

    if (selectedStatus.value != 'All Status') {
      filtered = filtered.where((s) => s.status.toUpperCase() == selectedStatus.value.toUpperCase());
    }

    if (selectedCustomerId.value != 'All Customers') {
      // Find customer ID from name or match name directly if stored in invoice
      filtered = filtered.where((s) {
        if (s.customerId == null) return false;
        final customer = customers.firstWhereOrNull((c) => c.name == selectedCustomerId.value);
        return s.customerId == customer?.id;
      });
    }
    
    return filtered.toList();
  }

  List<Invoice> get paginatedSales {
    final filtered = filteredSales;
    final start = (currentPage.value - 1) * rowsPerPage.value;
    if (start >= filtered.length) return [];
    final end = start + rowsPerPage.value;
    return filtered.sublist(start, end > filtered.length ? filtered.length : end);
  }

  int get totalPages {
    final count = filteredSales.length;
    if (count <= 0) return 1;
    return (count / rowsPerPage.value).ceil();
  }

  void nextPage() {
    if (currentPage.value < totalPages) currentPage.value++;
  }

  void previousPage() {
    if (currentPage.value > 1) currentPage.value--;
  }

  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId) async {
    return await (db.select(db.invoiceItems)..where((t) => t.invoiceId.equals(invoiceId))).get();
  }
}