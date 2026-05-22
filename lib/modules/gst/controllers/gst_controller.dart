import 'package:get/get.dart';
import '../../../database/database.dart';
import 'package:drift/drift.dart' as drift;

class GstController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  
  final RxDouble totalTaxCollected = 0.0.obs;
  final RxDouble taxableAmount = 0.0.obs;
  final RxBool isLoading = false.obs;

  final RxList<Invoice> gstInvoices = <Invoice>[].obs;

  @override
  void onInit() {
    super.onInit();
    generateGstReport();
  }

  Future<void> generateGstReport() async {
    isLoading.value = true;
    try {
      final list = await db.select(db.invoices).get();
      gstInvoices.assignAll(list.reversed.toList());
      
      totalTaxCollected.value = list.fold(0, (sum, item) => sum + item.taxTotal);
      taxableAmount.value = list.fold(0, (sum, item) => sum + item.subtotal);
    } finally {
      isLoading.value = false;
    }
  }
}
