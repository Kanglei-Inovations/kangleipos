import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/gst_controller.dart';

class GstView extends GetView<GstController> {
  const GstView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'GST & Tax Reports',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTaxCards(),
            const SizedBox(height: 32),
            _buildTableHeader(),
            Expanded(child: _buildGstList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxCards() {
    return Obx(() => Row(
      children: [
        Expanded(child: _buildSummaryCard('Total Tax Collected', '₹${controller.totalTaxCollected.value.toStringAsFixed(2)}', Colors.blue)),
        const SizedBox(width: 24),
        Expanded(child: _buildSummaryCard('Taxable Sales', '₹${controller.taxableAmount.value.toStringAsFixed(2)}', Colors.green)),
      ],
    ));
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
      child: const Row(
        children: [
          Expanded(child: Text('INVOICE NO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          Expanded(child: Text('TAXABLE AMT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          Expanded(child: Text('GST AMT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          Expanded(child: Text('GRAND TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildGstList() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.gstInvoices.isEmpty) return const Center(child: Text('No tax data found.'));

        return ListView.separated(
          itemCount: controller.gstInvoices.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final inv = controller.gstInvoices[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              title: Row(
                children: [
                  Expanded(child: Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('₹${inv.subtotal.toStringAsFixed(2)}')),
                  Expanded(child: Text('₹${inv.taxTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                  Expanded(child: Text('₹${inv.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
