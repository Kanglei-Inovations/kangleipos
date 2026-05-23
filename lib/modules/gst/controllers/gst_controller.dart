import 'package:get/get.dart';
import '../../../database/database.dart';
import 'package:drift/drift.dart' as drift;

class GstController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  
  final RxDouble totalTaxCollected = 0.0.obs;
  final RxDouble taxableAmount = 0.0.obs;
  final RxBool isLoading = false.obs;

  final RxList<Invoice> gstInvoices = <Invoice>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedTab = 'GSTR-1'.obs;

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

  // KPIs
  double get totalOutputTax => totalTaxCollected.value;
  double get totalInputTaxCredit => totalTaxCollected.value * 0.4; // Mocked
  double get netTaxPayable => totalOutputTax - totalInputTaxCredit;
  double get taxLiability => totalOutputTax;

  List<Invoice> get filteredInvoices {
    return gstInvoices.where((i) {
      final q = searchQuery.value.toLowerCase();
      return i.invoiceNumber.toLowerCase().contains(q);
    }).toList();
  }
}
