import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/layout/main_layout.dart';
import '../../../widgets/layout/contact_list_view.dart';
import '../controllers/customer_controller.dart';
import '../../../database/database.dart';
import 'add_customer_dialog.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Customers',
      child: Obx(() => ContactListView<Customer>(
        title: 'Customers',
        items: controller.filteredCustomers,
        isLoading: controller.isLoading.value,
        onSearch: (v) => controller.searchQuery.value = v,
        onAdd: () => Get.dialog(AddCustomerDialog()),
        itemBuilder: (customer) => _buildCustomerTile(customer),
      )),
    );
  }

  Widget _buildCustomerTile(Customer customer) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
        child: Text(customer.name[0].toUpperCase(), style: TextStyle(color: Get.theme.primaryColor, fontWeight: FontWeight.bold)),
      ),
      title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(customer.phone ?? customer.email ?? 'No contact info'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Balance Due', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('₹${customer.balanceDue.toStringAsFixed(2)}', 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: customer.balanceDue > 0 ? Colors.red : Colors.green
                )
              ),
            ],
          ),
          const SizedBox(width: 24),
          IconButton(icon: const Icon(Icons.history, color: Colors.blue), onPressed: () {
            // TODO: View Ledger
          }),
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => Get.dialog(AddCustomerDialog(customer: customer))),
        ],
      ),
    );
  }
}
