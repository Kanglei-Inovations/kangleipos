import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import '../../../database/database.dart';

class ReportsController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();

  final RxDouble totalSales = 0.0.obs;
  final RxDouble totalPurchases = 0.0.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble netProfit = 0.0.obs;
  final RxDouble grossProfit = 0.0.obs;
  final RxInt totalInvoices = 0.obs;
  
  final RxList<Invoice> recentSales = <Invoice>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'All Reports'.obs;

  @override
  void onInit() {
    super.onInit();
    refreshReportData();
  }

  Future<void> refreshReportData() async {
    isLoading.value = true;
    try {
      final salesList = await db.select(db.invoices).get();
      final expenseList = await db.select(db.expenses).get();
      final purchaseList = await db.select(db.purchases).get();

      totalSales.value = salesList.fold(0.0, (sum, item) => sum + item.grandTotal);
      totalExpenses.value = expenseList.fold(0.0, (sum, item) => sum + item.amount);
      totalPurchases.value = purchaseList.fold(0.0, (sum, item) => sum + item.grandTotal);
      
      // Mocked Gross Profit (Sales - Cost of Goods Sold)
      grossProfit.value = totalSales.value * 0.4;
      netProfit.value = grossProfit.value - totalExpenses.value;
      totalInvoices.value = salesList.length;
      
      recentSales.assignAll(salesList.reversed.take(10).toList());
    } finally {
      isLoading.value = false;
    }
  }

  // Analytics Helpers
  Map<String, double> get salesByCategory {
    return {
      'Electronics': 38,
      'Mobiles': 25,
      'Accessories': 18,
      'Home Appliances': 12,
      'Others': 7,
    };
  }

  Map<String, double> get profitLossData {
    return {
      'Total Revenue': totalSales.value,
      'Cost of Goods Sold': totalSales.value * 0.6,
      'Total Expenses': totalExpenses.value,
      'Net Profit': netProfit.value,
    };
  }
}
