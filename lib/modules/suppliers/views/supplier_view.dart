import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/layout/main_layout.dart';
import '../../../widgets/layout/contact_list_view.dart';
import '../controllers/supplier_controller.dart';
import '../../../database/database.dart';
import 'add_supplier_dialog.dart';

class SupplierView extends GetView<SupplierController> {
  const SupplierView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Suppliers',
      child: Obx(() => ContactListView<Supplier>(
        title: 'Suppliers',
        items: controller.filteredSuppliers,
        isLoading: controller.isLoading.value,
        onSearch: (v) => controller.searchQuery.value = v,
        onAdd: () => Get.dialog(AddSupplierDialog()),
        itemBuilder: (supplier) => _buildSupplierTile(supplier),
      )),
    );
  }

  Widget _buildSupplierTile(Supplier supplier) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Colors.orange.withOpacity(0.1),
        child: Text(supplier.name[0].toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
      ),
      title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(supplier.phone ?? supplier.email ?? 'No contact info'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Credit Balance', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('₹${supplier.balanceDue.toStringAsFixed(2)}', 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: supplier.balanceDue > 0 ? Colors.red : Colors.green
                )
              ),
            ],
          ),
          const SizedBox(width: 24),
          IconButton(icon: const Icon(Icons.history, color: Colors.blue), onPressed: () {}),
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => Get.dialog(AddSupplierDialog(supplier: supplier))),
        ],
      ),
    );
  }
}
