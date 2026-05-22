import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/inventory_controller.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Inventory & Stock Management',
      child: Container(
        color: const Color(0xFFF5F7FB),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildInventoryKPIs(),
              const SizedBox(height: 32),
              const Text('Management Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              Expanded(child: _buildManagementGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stock Control', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        Text('Manage stock levels, transfers, adjustments and movements.', style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildInventoryKPIs() {
    return Row(
      children: [
        _kpiCard('Inventory Value', '₹0.00', Icons.account_balance_wallet_rounded, Colors.blue),
        const SizedBox(width: 20),
        _kpiCard('Low Stock Items', '0', Icons.warning_amber_rounded, Colors.orange),
        const SizedBox(width: 20),
        _kpiCard('Warehouse Capacity', '85%', Icons.warehouse_rounded, Colors.green),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementGrid() {
    final tools = [
      {'title': 'Stock Adjustment', 'icon': Icons.adjust_rounded, 'color': Colors.indigo, 'route': AppRoutes.STOCK_ADJUSTMENT},
      {'title': 'Stock Transfer', 'icon': Icons.swap_horiz_rounded, 'color': Colors.blue, 'route': AppRoutes.STOCK_TRANSFER},
      {'title': 'Damage stock', 'icon': Icons.dangerous_outlined, 'color': Colors.red, 'route': null},
      {'title': 'Movement Logs', 'icon': Icons.history_edu_rounded, 'color': Colors.orange, 'route': null},
      {'title': 'Warehouse Mgt', 'icon': Icons.store_mall_directory_rounded, 'color': Colors.teal, 'route': null},
      {'title': 'Inventory Valuation', 'icon': Icons.assessment_rounded, 'color': Colors.purple, 'route': null},
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 2.2,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return InkWell(
          onTap: () {
            if (tool['route'] != null) Get.toNamed(tool['route'] as String);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Icon(tool['icon'] as IconData, color: tool['color'] as Color, size: 28),
                const SizedBox(width: 16),
                Text(tool['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
