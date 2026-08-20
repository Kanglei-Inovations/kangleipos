import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../../../database/database.dart';
import 'package:uuid/uuid.dart';
import '../../../sync/sync_client.dart';

class CustomerController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final _uuid = const Uuid();

  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<Customer?> selectedCustomerForDetails = Rx<Customer?>(null);

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      final list = await db.select(db.customers).get();
      customers.assignAll(list);
      if (customers.isNotEmpty && selectedCustomerForDetails.value == null) {
        selectedCustomerForDetails.value = customers.first;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // KPIs
  int get totalCustomers => customers.length;
  int get activeCustomers => customers.length; // Mocked
  int get inactiveCustomers => 0; // Mocked
  double get totalReceivable => customers.fold(0.0, (sum, c) => sum + c.balanceDue);
  double get overdueAmount => totalReceivable * 0.15; // Mocked

  List<Customer> get filteredCustomers {
    return customers.where((c) {
      final q = searchQuery.value.toLowerCase();
      return c.name.toLowerCase().contains(q) || 
             (c.phone?.contains(q) ?? false) || 
             (c.email?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> addCustomer({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? gst,
    double openingBalance = 0,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final newCust = Customer(
      id: id,
      name: name,
      phone: phone,
      email: email,
      address: address,
      gstNumber: gst,
      balanceDue: openingBalance,
      creditLimit: 0.0,
      loyaltyPoints: 0.0,
      createdAt: now,
    );

    await db.into(db.customers).insert(CustomersCompanion(
      id: d.Value(id),
      name: d.Value(name),
      phone: d.Value(phone),
      email: d.Value(email),
      address: d.Value(address),
      gstNumber: d.Value(gst),
      balanceDue: d.Value(openingBalance),
      createdAt: d.Value(now),
    ));
    await refreshData();
    _pushCustomerToDesktop(newCust);
  }

  Future<void> updateCustomer(Customer customer) async {
    await db.update(db.customers).replace(customer);
    await refreshData();
    _pushCustomerToDesktop(customer);
  }

  void _pushCustomerToDesktop(Customer cust) async {
    try {
      if (!Get.isRegistered<SyncClientService>()) return;
      final client = Get.find<SyncClientService>();
      if (!client.isConnected.value) return;

      await client.pushToDesktop([], [], customers: [
        {
          'id': cust.id,
          'name': cust.name,
          'phone': cust.phone,
          'email': cust.email,
          'address': cust.address,
          'gstNumber': cust.gstNumber,
          'balanceDue': cust.balanceDue,
          'creditLimit': cust.creditLimit,
          'loyaltyPoints': cust.loyaltyPoints,
          'createdAt': cust.createdAt.toIso8601String(),
        }
      ]);
    } catch (_) {}
  }

  Future<void> deleteCustomer(String id) async {
    await (db.delete(db.customers)..where((t) => t.id.equals(id))).go();
    await refreshData();
  }

  Future<List<Invoice>> getCustomerInvoices(String customerId) async {
    return await (db.select(db.invoices)..where((t) => t.customerId.equals(customerId))).get();
  }

  Future<void> receivePayment(String customerId, double amount, String paymentMethod) async {
    final customer = customers.firstWhereOrNull((c) => c.id == customerId);
    if (customer == null) return;

    final newBalance = (customer.balanceDue - amount).clamp(0.0, double.infinity);
    await (db.update(db.customers)..where((t) => t.id.equals(customerId))).write(
      CustomersCompanion(balanceDue: d.Value(newBalance)),
    );
    await refreshData();
    Get.snackbar('Payment Recorded', 'Received ₹${amount.toStringAsFixed(2)} from ${customer.name}');
  }
}
