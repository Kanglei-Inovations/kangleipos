import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import '../../../database/database.dart';

class ReportsController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final RxDouble totalSales = 0.0.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble netProfit = 0.0.obs;
  final RxInt totalInvoices = 0.obs;
  
  final RxList<Invoice> recentSales = <Invoice>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    generateDailyReport();
  }

  Future<void> generateDailyReport() async {
    isLoading.value = true;
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // Fetch Sales
      final sales = await (db.select(db.invoices)..where((t) => t.createdAt.isBiggerOrEqual(drift.Constant(startOfDay)))).get();
      
      // Fetch Expenses
      final expenses = await (db.select(db.expenses)..where((t) => t.expenseDate.isBiggerOrEqual(drift.Constant(startOfDay)))).get();

      totalSales.value = sales.fold(0, (sum, item) => sum + item.grandTotal);
      totalExpenses.value = expenses.fold(0, (sum, item) => sum + item.amount);
      netProfit.value = totalSales.value - totalExpenses.value;
      totalInvoices.value = sales.length;
      
      recentSales.assignAll(sales.reversed.take(10).toList());
    } finally {
      isLoading.value = false;
    }
  }

  // TODO: Add methods for Monthly, GST and Stock reports
}
