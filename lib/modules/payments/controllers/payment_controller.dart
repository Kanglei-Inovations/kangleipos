import 'package:get/get.dart';
import '../../../database/database.dart';

class PaymentTransaction {
  final String id;
  final DateTime date;
  final String type; // 'PAYMENT_IN' or 'PAYMENT_OUT'
  final String category; // 'Sales', 'Customer Settlement', 'Purchase', 'Supplier Settlement', 'Expense'
  final String partyName; // Customer / Supplier / Recipient
  final double amount;
  final String paymentMode; // 'CASH', 'UPI', 'CARD', 'BANK'
  final String referenceNo;
  final String status;

  PaymentTransaction({
    required this.id,
    required this.date,
    required this.type,
    required this.category,
    required this.partyName,
    required this.amount,
    required this.paymentMode,
    required this.referenceNo,
    this.status = 'COMPLETED',
  });
}

class PaymentController extends GetxController {
  final db = Get.find<AppDatabase>();

  final RxList<PaymentTransaction> transactions = <PaymentTransaction>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedTypeFilter = 'ALL'.obs; // 'ALL', 'PAYMENT_IN', 'PAYMENT_OUT'
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      final List<PaymentTransaction> list = [];

      // 1. Fetch Invoices (Payment In)
      final invoices = await db.select(db.invoices).get();
      final customers = await db.select(db.customers).get();
      final custMap = {for (var c in customers) c.id: c.name};

      for (var inv in invoices) {
        if (inv.status == 'PAID') {
          list.add(PaymentTransaction(
            id: 'TXN-INV-${inv.invoiceNumber}',
            date: inv.createdAt,
            type: 'PAYMENT_IN',
            category: 'Sales Invoice',
            partyName: custMap[inv.customerId] ?? 'Walk-in Customer',
            amount: inv.grandTotal,
            paymentMode: inv.paymentMethod,
            referenceNo: 'INV-${inv.invoiceNumber}',
          ));
        }
      }

      // 2. Fetch Expenses (Payment Out)
      final expensesList = await db.select(db.expenses).get();
      for (var exp in expensesList) {
        final shortId = exp.id.length > 6 ? exp.id.substring(0, 6) : exp.id;
        list.add(PaymentTransaction(
          id: 'TXN-EXP-$shortId',
          date: exp.expenseDate,
          type: 'PAYMENT_OUT',
          category: 'Expense (${exp.category})',
          partyName: exp.description,
          amount: exp.amount,
          paymentMode: 'CASH',
          referenceNo: 'EXP-$shortId',
        ));
      }

      // 3. Fetch Purchases (Payment Out)
      final purchasesList = await db.select(db.purchases).get();
      final suppliersList = await db.select(db.suppliers).get();
      final suppMap = {for (var s in suppliersList) s.id: s.name};

      for (var pur in purchasesList) {
        list.add(PaymentTransaction(
          id: 'TXN-PUR-${pur.purchaseNumber}',
          date: pur.purchaseDate,
          type: 'PAYMENT_OUT',
          category: 'Stock Purchase',
          partyName: suppMap[pur.supplierId] ?? 'Vendor Supplier',
          amount: pur.grandTotal,
          paymentMode: 'CASH',
          referenceNo: 'PO-${pur.purchaseNumber}',
        ));
      }

      // Sort by date descending
      list.sort((a, b) => b.date.compareTo(a.date));
      transactions.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  // KPIs
  double get totalPaymentIn => transactions
      .where((t) => t.type == 'PAYMENT_IN')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalPaymentOut => transactions
      .where((t) => t.type == 'PAYMENT_OUT')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get remainingNetBalance => totalPaymentIn - totalPaymentOut;

  double get cashBalance => transactions.fold(0.0, (sum, t) {
        if (t.paymentMode.toUpperCase() == 'CASH') {
          return t.type == 'PAYMENT_IN' ? sum + t.amount : sum - t.amount;
        }
        return sum;
      });

  double get upiBalance => transactions.fold(0.0, (sum, t) {
        if (t.paymentMode.toUpperCase() == 'UPI') {
          return t.type == 'PAYMENT_IN' ? sum + t.amount : sum - t.amount;
        }
        return sum;
      });

  double get cardBalance => transactions.fold(0.0, (sum, t) {
        if (t.paymentMode.toUpperCase() == 'CARD') {
          return t.type == 'PAYMENT_IN' ? sum + t.amount : sum - t.amount;
        }
        return sum;
      });

  List<PaymentTransaction> get filteredTransactions {
    return transactions.where((t) {
      if (selectedTypeFilter.value != 'ALL' && t.type != selectedTypeFilter.value) {
        return false;
      }
      final q = searchQuery.value.toLowerCase();
      if (q.isEmpty) return true;
      return t.id.toLowerCase().contains(q) ||
          t.partyName.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          t.referenceNo.toLowerCase().contains(q);
    }).toList();
  }
}
