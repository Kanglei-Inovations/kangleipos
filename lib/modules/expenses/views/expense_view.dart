import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/expense_controller.dart';
import 'add_expense_dialog.dart';

class ExpenseView extends GetView<ExpenseController> {
  const ExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Expense Management',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(child: _buildExpenseList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (v) => controller.searchQuery.value = v,
            decoration: InputDecoration(
              hintText: 'Search expenses by description or category...',
              prefixIcon: const Icon(Icons.search),
              fillColor: Get.theme.cardColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => Get.dialog(AddExpenseDialog()),
          icon: const Icon(Icons.add),
          label: const Text('ADD EXPENSE'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseList() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        
        final list = controller.filteredExpenses;
        if (list.isEmpty) return const Center(child: Text('No expenses recorded.'));

        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final e = list[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.red),
              ),
              title: Text(e.description, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${e.category} • ${DateFormat('dd MMM yyyy').format(e.expenseDate)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('₹${e.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => _confirmDelete(e),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _confirmDelete(dynamic e) {
    Get.defaultDialog(
      title: 'Delete Expense',
      middleText: 'Are you sure you want to delete this expense?',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteExpense(e.id);
        Get.back();
      },
    );
  }
}
