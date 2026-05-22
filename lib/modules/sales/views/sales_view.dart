import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/sales_controller.dart';
import '../../../database/database.dart';

class SalesView extends GetView<SalesController> {
  const SalesView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Sales History',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(child: _buildSalesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('All Invoices', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          onPressed: () => controller.refreshSales(),
          icon: const Icon(Icons.refresh),
          label: const Text('REFRESH'),
        ),
      ],
    );
  }

  Widget _buildSalesList() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.sales.isEmpty) return const Center(child: Text('No sales found.'));

        return ListView.separated(
          itemCount: controller.sales.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final sale = controller.sales[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              leading: const Icon(Icons.receipt_long, color: Colors.blue),
              title: Text(sale.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(sale.createdAt)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${sale.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(sale.paymentMethod, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  IconButton(icon: const Icon(Icons.visibility_outlined), onPressed: () => _showInvoiceDetails(sale)),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _showInvoiceDetails(Invoice sale) async {
    final items = await controller.getInvoiceItems(sale.id);
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Invoice: ${sale.invoiceNumber}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final it = items[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(it.productName),
                    subtitle: Text('${it.quantity} x ₹${it.unitPrice}'),
                    trailing: Text('₹${it.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('₹${sale.grandTotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Get.theme.primaryColor)),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
