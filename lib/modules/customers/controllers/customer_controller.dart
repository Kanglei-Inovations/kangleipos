import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../../../database/database.dart';
import 'package:uuid/uuid.dart';

class CustomerController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final _uuid = const Uuid();

  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

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
    } finally {
      isLoading.value = false;
    }
  }

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
    await db.into(db.customers).insert(CustomersCompanion(
      id: d.Value(id),
      name: d.Value(name),
      phone: d.Value(phone),
      email: d.Value(email),
      address: d.Value(address),
      gstNumber: d.Value(gst),
      balanceDue: d.Value(openingBalance),
    ));
    await refreshData();
  }

  Future<void> updateCustomer(Customer customer) async {
    await db.update(db.customers).replace(customer);
    await refreshData();
  }

  Future<void> deleteCustomer(String id) async {
    await (db.delete(db.customers)..where((t) => t.id.equals(id))).go();
    await refreshData();
  }

  Future<List<Invoice>> getCustomerInvoices(String customerId) async {
    return await (db.select(db.invoices)..where((t) => t.customerId.equals(customerId))).get();
  }
}
