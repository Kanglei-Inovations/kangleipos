import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Analytics & Reports',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateFilter(),
              const SizedBox(height: 24),
              _buildKPISection(),
              const SizedBox(height: 32),
              const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSalesTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Business Performance Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          onPressed: () => controller.generateDailyReport(),
          icon: const Icon(Icons.refresh),
          label: const Text('REFRESH REPORT'),
        )
      ],
    );
  }

  Widget _buildKPISection() {
    return Obx(() => Row(
      children: [
        Expanded(child: _buildKPICard('Total Sales', '₹${controller.totalSales.value.toStringAsFixed(2)}', Icons.payments, Colors.green)),
        const SizedBox(width: 24),
        Expanded(child: _buildKPICard('Total Expenses', '₹${controller.totalExpenses.value.toStringAsFixed(2)}', Icons.shopping_bag, Colors.red)),
        const SizedBox(width: 24),
        Expanded(child: _buildKPICard('Net Profit', '₹${controller.netProfit.value.toStringAsFixed(2)}', Icons.trending_up, Colors.blue)),
        const SizedBox(width: 24),
        Expanded(child: _buildKPICard('Invoices', '${controller.totalInvoices.value}', Icons.receipt_long, Colors.orange)),
      ],
    ));
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSalesTable() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Obx(() {
        if (controller.isLoading.value) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        if (controller.recentSales.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('No transactions for selected period.')));

        return Column(
          children: [
            _buildTableHeader(),
            ...controller.recentSales.map((s) => _buildTableRow(s)),
          ],
        );
      }),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
      child: const Row(
        children: [
          Expanded(child: Text('INVOICE NO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          Expanded(child: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          Expanded(child: Text('METHOD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          Expanded(child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildTableRow(dynamic s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        children: [
          Expanded(child: Text(s.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
          Expanded(child: Text(DateFormat('HH:mm').format(s.createdAt))),
          Expanded(child: Text(s.paymentMethod)),
          Expanded(child: Text('₹${s.grandTotal.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
