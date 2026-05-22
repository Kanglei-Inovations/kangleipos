import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';

class AddExpenseDialog extends StatelessWidget {
  AddExpenseDialog({super.key});

  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _amount = TextEditingController();
  final RxString _selectedCategory = 'Others'.obs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpenseController>();

    return AlertDialog(
      title: const Text('Add Business Expense'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => DropdownButtonFormField<String>(
                value: _selectedCategory.value,
                decoration: const InputDecoration(labelText: 'Category'),
                items: controller.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => _selectedCategory.value = v!,
              )),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description (e.g. Electricity Bill Jan)'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                decoration: const InputDecoration(labelText: 'Amount (₹)', prefixIcon: Icon(Icons.currency_rupee)),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              controller.addExpense(
                category: _selectedCategory.value,
                description: _description.text,
                amount: double.tryParse(_amount.text) ?? 0,
              );
              Get.back();
            }
          }, 
          child: const Text('SAVE EXPENSE')
        ),
      ],
    );
  }
}
