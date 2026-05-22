import 'package:get/get.dart';
import '../../../database/database.dart';

class SalesController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  
  final RxList<Invoice> sales = <Invoice>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshSales();
  }

  Future<void> refreshSales() async {
    isLoading.value = true;
    try {
      final list = await db.select(db.invoices).get();
      sales.assignAll(list.reversed.toList());
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId) async {
    return await (db.select(db.invoiceItems)..where((t) => t.invoiceId.equals(invoiceId))).get();
  }
}
