import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../../../database/database.dart';
import 'package:uuid/uuid.dart';

class SupplierController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final _uuid = const Uuid();

  final RxList<Supplier> suppliers = <Supplier>[].obs;
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
      final list = await db.select(db.suppliers).get();
      suppliers.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  List<Supplier> get filteredSuppliers {
    return suppliers.where((s) {
      final q = searchQuery.value.toLowerCase();
      return s.name.toLowerCase().contains(q) || 
             (s.phone?.contains(q) ?? false) || 
             (s.email?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> addSupplier({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? gst,
    double openingBalance = 0,
  }) async {
    final id = _uuid.v4();
    await db.into(db.suppliers).insert(SuppliersCompanion(
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

  Future<void> updateSupplier(Supplier supplier) async {
    await db.update(db.suppliers).replace(supplier);
    await refreshData();
  }

  Future<void> deleteSupplier(String id) async {
    await (db.delete(db.suppliers)..where((t) => t.id.equals(id))).go();
    await refreshData();
  }
}
