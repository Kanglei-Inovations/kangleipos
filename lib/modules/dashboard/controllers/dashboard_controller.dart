import 'package:get/get.dart';
import '../../../database/database.dart';
import 'package:drift/drift.dart' as d;

class DashboardController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final RxDouble todaySales = 0.0.obs;
  final RxInt todayOrders = 0.obs;
  final RxDouble todayProfit = 0.0.obs;
  final RxInt lowStockCount = 0.obs;
  
  final RxList<Invoice> recentTransactions = <Invoice>[].obs;
  final RxList<Product> topSellingProducts = <Product>[].obs;
  
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    isLoading.value = true;
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // 1. Fetch Today's Stats
      final sales = await (db.select(db.invoices)..where((t) => t.createdAt.isBiggerOrEqual(d.Constant(startOfDay)))).get();
      final expenses = await (db.select(db.expenses)..where((t) => t.expenseDate.isBiggerOrEqual(d.Constant(startOfDay)))).get();
      
      todaySales.value = sales.fold(0.0, (sum, item) => sum + item.grandTotal);
      todayOrders.value = sales.length;
      
      double totalExpense = expenses.fold(0.0, (sum, item) => sum + item.amount);
      todayProfit.value = todaySales.value - totalExpense;

      // 2. Fetch Low Stock Alerts
      final allProducts = await db.select(db.products).get();
      lowStockCount.value = allProducts.where((p) => p.stockQuantity <= p.lowStockAlert).length;

      // 3. Fetch Recent Transactions
      recentTransactions.assignAll(sales.reversed.take(5).toList());
      
      // 4. Update product list (for simple stats)
      // For top selling products, we would usually query invoice items, but let's keep it simple for now
    } finally {
      isLoading.value = false;
    }
  }
}
