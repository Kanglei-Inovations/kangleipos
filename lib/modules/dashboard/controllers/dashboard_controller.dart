import 'package:get/get.dart';
import '../../../database/database.dart';
import 'package:drift/drift.dart' as d;

class DashboardTransaction {
  final String id;
  final String title;
  final String subtitle;
  final String type; // 'SELL', 'PURCHASE', 'EXPENSE'
  final double amount;
  final String paymentMethod;
  final DateTime date;

  DashboardTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.amount,
    required this.paymentMethod,
    required this.date,
  });
}

class DashboardTopProduct {
  final String id;
  final String name;
  final int soldQuantity;
  final double totalRevenue;

  DashboardTopProduct({
    required this.id,
    required this.name,
    required this.soldQuantity,
    required this.totalRevenue,
  });
}

class DashboardController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final RxDouble todaySales = 0.0.obs;
  final RxInt todayOrders = 0.obs;
  final RxDouble todayProfit = 0.0.obs;
  final RxDouble todayExpenses = 0.0.obs;
  final RxDouble todayPurchases = 0.0.obs;
  final RxDouble totalDue = 0.0.obs;
  final RxInt totalCustomers = 0.obs;
  final RxInt lowStockCount = 0.obs;
  
  final RxList<DashboardTransaction> unifiedTransactions = <DashboardTransaction>[].obs;
  final RxList<DashboardTopProduct> topSellingProducts = <DashboardTopProduct>[].obs;
  
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
      final purchases = await (db.select(db.purchases)..where((t) => t.purchaseDate.isBiggerOrEqual(d.Constant(startOfDay)))).get();
      final customers = await db.select(db.customers).get();
      
      todaySales.value = sales.fold(0.0, (sum, item) => sum + item.grandTotal);
      todayOrders.value = sales.length;
      totalCustomers.value = customers.length;
      
      todayExpenses.value = expenses.fold(0.0, (sum, item) => sum + item.amount);
      todayPurchases.value = purchases.fold(0.0, (sum, item) => sum + item.grandTotal);
      totalDue.value = customers.fold(0.0, (sum, item) => sum + item.balanceDue);
      todayProfit.value = todaySales.value - todayExpenses.value;

      // 2. Fetch Low Stock Alerts
      final allProducts = await db.select(db.products).get();
      lowStockCount.value = allProducts.where((p) => p.stockQuantity <= p.lowStockAlert).length;

      // 3. Fetch Real Recent Unified Transactions (SELL, PURCHASE, EXPENSE/CASHOUT)
      final allInvoices = await db.select(db.invoices).get();
      final allPurchases = await db.select(db.purchases).get();
      final allExpenses = await db.select(db.expenses).get();

      final List<DashboardTransaction> txList = [];

      for (final inv in allInvoices) {
        txList.add(DashboardTransaction(
          id: inv.id,
          title: inv.invoiceNumber,
          subtitle: 'Sale (${inv.paymentMethod})',
          type: 'SELL',
          amount: inv.grandTotal,
          paymentMethod: inv.paymentMethod,
          date: inv.createdAt,
        ));
      }

      for (final pur in allPurchases) {
        txList.add(DashboardTransaction(
          id: pur.id,
          title: pur.purchaseNumber,
          subtitle: 'Purchase / Stock In',
          type: 'PURCHASE',
          amount: pur.grandTotal,
          paymentMethod: 'BANK',
          date: pur.purchaseDate,
        ));
      }

      for (final exp in allExpenses) {
        txList.add(DashboardTransaction(
          id: exp.id,
          title: exp.description.isNotEmpty ? exp.description : exp.category,
          subtitle: 'Expense / Cashout (${exp.category})',
          type: 'EXPENSE',
          amount: exp.amount,
          paymentMethod: 'CASH',
          date: exp.expenseDate,
        ));
      }

      txList.sort((a, b) => b.date.compareTo(a.date));
      unifiedTransactions.assignAll(txList.take(6).toList());

      // 4. Fetch Real Top Selling Products from InvoiceItems
      final allItems = await db.select(db.invoiceItems).get();
      final Map<String, int> qtyMap = {};
      final Map<String, double> revenueMap = {};

      for (final item in allItems) {
        final pId = item.productId;
        qtyMap[pId] = (qtyMap[pId] ?? 0) + item.quantity.toInt();
        revenueMap[pId] = (revenueMap[pId] ?? 0.0) + item.total;
      }

      final List<DashboardTopProduct> topList = [];
      final prodMap = {for (var p in allProducts) p.id: p.name};

      qtyMap.forEach((pId, qty) {
        final pName = prodMap[pId] ?? 'Product #$pId';
        topList.add(DashboardTopProduct(
          id: pId,
          name: pName,
          soldQuantity: qty,
          totalRevenue: revenueMap[pId] ?? 0.0,
        ));
      });

      topList.sort((a, b) => b.soldQuantity.compareTo(a.soldQuantity));

      // Fallback to top products from catalog if no sales yet
      if (topList.isEmpty) {
        for (final p in allProducts.take(5)) {
          topList.add(DashboardTopProduct(
            id: p.id,
            name: p.name,
            soldQuantity: 0,
            totalRevenue: 0.0,
          ));
        }
      }

      topSellingProducts.assignAll(topList.take(5).toList());
    } finally {
      isLoading.value = false;
    }
  }
}
