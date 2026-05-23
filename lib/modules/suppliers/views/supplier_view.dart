import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../database/database.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/supplier_controller.dart';
import 'add_supplier_dialog.dart';

class SupplierView extends GetView<SupplierController> {
  const SupplierView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Suppliers',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1280;

          return Obx(() {
            if (controller.isLoading.value && controller.suppliers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SupplierKpiGrid(width: width),
                  const SizedBox(height: 18),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _MainSupplierContent()),
                        const SizedBox(width: 18),
                        const SizedBox(width: 330, child: _SupplierRightRail()),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _MainSupplierContent(),
                        const SizedBox(height: 18),
                        const _SupplierRightRail(),
                      ],
                    ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}

class _SupplierKpiGrid extends GetView<SupplierController> {
  final double width;

  const _SupplierKpiGrid({required this.width});

  @override
  Widget build(BuildContext context) {
    final columns = width >= 1180
        ? 5
        : width >= 860
            ? 3
            : width >= 560
                ? 2
                : 1;

    final kpis = [
      _SupplierKpiData(
        title: 'Total Suppliers',
        value: controller.totalSuppliers.toDouble(),
        growth: 8.6,
        icon: Icons.groups_outlined,
        gradient: [const Color(0xFF8B5CF6), const Color(0xFF6366F1)],
        sparkline: [25, 30, 28, 35, 32, 40, 38],
        isCurrency: false,
      ),
      _SupplierKpiData(
        title: 'Total Payable',
        value: controller.totalPayable,
        growth: 12.3,
        icon: Icons.account_balance_wallet_outlined,
        gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        sparkline: [20, 22, 25, 23, 28, 30, 35],
      ),
      _SupplierKpiData(
        title: 'Amount Paid',
        value: controller.amountPaid,
        growth: 9.4,
        icon: Icons.credit_score_outlined,
        gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        sparkline: [30, 28, 32, 35, 30, 38, 40],
      ),
      _SupplierKpiData(
        title: 'Overdue Amount',
        value: controller.overdueAmount,
        growth: -6.2,
        icon: Icons.schedule_outlined,
        gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        sparkline: [40, 38, 35, 30, 25, 20, 15],
      ),
      _SupplierKpiData(
        title: 'Purchase Amount',
        value: controller.totalPurchaseAmount,
        growth: 10.7,
        icon: Icons.shopping_cart_outlined,
        gradient: [const Color(0xFFEC4899), const Color(0xFFDB2777)],
        sparkline: [25, 20, 30, 35, 40, 38, 45],
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kpis.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 160,
      ),
      itemBuilder: (context, index) {
        return _SupplierKpiCard(data: kpis[index])
            .animate()
            .fadeIn(delay: (70 * index).ms, duration: 420.ms)
            .slideY(begin: 0.14, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _SupplierKpiData {
  final String title;
  final double value;
  final double growth;
  final IconData icon;
  final List<Color> gradient;
  final List<double> sparkline;
  final bool isCurrency;

  const _SupplierKpiData({
    required this.title,
    required this.value,
    required this.growth,
    required this.icon,
    required this.gradient,
    required this.sparkline,
    this.isCurrency = true,
  });
}

class _SupplierKpiCard extends StatelessWidget {
  final _SupplierKpiData data;

  const _SupplierKpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: data.gradient.first.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.gradient.first, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.isCurrency
                          ? NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(data.value)
                          : data.value.toInt().toString(),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        data.growth >= 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 14,
                        color: data.growth >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${data.growth.abs()}%',
                        style: TextStyle(
                          color: data.growth >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('vs last month', style: TextStyle(color: muted, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 80,
                height: 30,
                child: CustomPaint(
                  painter: _KpiSparklinePainter(points: data.sparkline, color: data.gradient.first),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiSparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _KpiSparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (points.length - 1);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final minVal = points.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    for (var i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - ((points[i] - minVal) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MainSupplierContent extends GetView<SupplierController> {
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Suppliers List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
              _SupplierSearchField(),
              const SizedBox(width: 12),
              _FilterDropdown(label: 'All Status'),
              const SizedBox(width: 12),
              _FilterDropdown(label: 'All Cities'),
              const SizedBox(width: 12),
              _ActionButton(icon: Icons.tune_rounded, label: 'Filters'),
              const SizedBox(width: 12),
              _AddSupplierButton(),
            ],
          ),
          const SizedBox(height: 20),
          _SupplierTable(),
          const SizedBox(height: 20),
          _TablePagination(),
        ],
      ),
    );
  }
}

class _SupplierSearchField extends GetView<SupplierController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Container(
      width: 240,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: muted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search supplier...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: muted, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;

  const _FilterDropdown({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted)),
          const SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: muted),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: muted),
          ),
        ],
      ),
    );
  }
}

class _AddSupplierButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: () => Get.dialog(AddSupplierDialog()),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_rounded, size: 18),
            SizedBox(width: 8),
            Text('Add Supplier', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _SupplierTable extends GetView<SupplierController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    final columns = ['#', 'Supplier', 'Contact', 'Phone', 'City', 'Total Purchase', 'Payable', 'Status', 'Action'];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9))),
          ),
          child: Row(
            children: [
              for (var i = 0; i < columns.length; i++)
                Expanded(
                  flex: i == 1 || i == 2 ? 3 : i == 0 ? 1 : 2,
                  child: Text(
                    columns[i],
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: muted),
                  ),
                ),
            ],
          ),
        ),
        Obx(() {
          final suppliers = controller.filteredSuppliers;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return _SupplierRow(supplier: supplier, index: index + 1);
            },
          );
        }),
      ],
    );
  }
}

class _SupplierRow extends GetView<SupplierController> {
  final Supplier supplier;
  final int index;

  const _SupplierRow({required this.supplier, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    // Mock data for display purposes
    final totalPurchase = supplier.balanceDue * 2.5; 
    final city = supplier.address?.split(',').last.trim() ?? 'N/A';
    final contactName = 'Mr. ${supplier.name.split(' ').first}';
    final contactEmail = supplier.email ?? '${supplier.name.split(' ').first.toLowerCase()}@example.com';
    
    final status = supplier.balanceDue > 50000 ? 'Overdue' : supplier.balanceDue > 0 ? 'Partial' : 'Paid';
    final statusColor = status == 'Paid' ? Colors.green : status == 'Partial' ? Colors.orange : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          // Index
          Expanded(flex: 1, child: Text('$index', style: TextStyle(fontWeight: FontWeight.w700, color: muted))),
          // Supplier
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Text(supplier.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('Electronics', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)), // Mock category
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contact
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contactName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(contactEmail, style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Phone
          Expanded(flex: 2, child: Text(supplier.phone ?? '+91 98765 43210', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          // City
          Expanded(flex: 2, child: Text(city, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          // Total Purchase
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(totalPurchase), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
          // Payable
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(supplier.balanceDue), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.red))),
          // Status
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor), textAlign: TextAlign.center),
              ),
            ),
          ),
          // Action
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _TableActionIcon(icon: Icons.visibility_outlined, onTap: () {}),
                _TableActionIcon(icon: Icons.edit_outlined, onTap: () => Get.dialog(AddSupplierDialog(supplier: supplier))),
                _TableActionIcon(icon: Icons.more_vert_rounded, onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _TableActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: Colors.grey),
      ),
    );
  }
}

class _TablePagination extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Showing 1 to 10 of 125 results', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        const Spacer(),
        _PaginationButton(icon: Icons.chevron_left_rounded),
        const SizedBox(width: 8),
        _PageNumber(number: 1, active: true),
        _PageNumber(number: 2),
        _PageNumber(number: 3),
        _PageNumber(number: 4),
        _PageNumber(number: 5),
        const Text('...', style: TextStyle(color: Colors.grey)),
        _PageNumber(number: 13),
        const SizedBox(width: 8),
        _PaginationButton(icon: Icons.chevron_right_rounded),
        const SizedBox(width: 16),
        const Text('Rows per page:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
          child: Row(children: const [Text('10', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)), SizedBox(width: 8), Icon(Icons.keyboard_arrow_down_rounded, size: 16)]),
        ),
      ],
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  const _PaginationButton({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 18, color: Colors.grey),
    );
  }
}

class _PageNumber extends StatelessWidget {
  final int number;
  final bool active;
  const _PageNumber({required this.number, this.active = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: active ? const Color(0xFF4F46E5) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
      child: Center(child: Text('$number', style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.w800, fontSize: 12))),
    );
  }
}

class _SupplierRightRail extends StatelessWidget {
  const _SupplierRightRail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _PayableSummaryChart(),
        SizedBox(height: 18),
        _TopSuppliersList(),
        SizedBox(height: 18),
        _RecentPurchaseInvoicesList(),
      ],
    );
  }
}

class _PayableSummaryChart extends GetView<SupplierController> {
  const _PayableSummaryChart();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;
    
    // Mock proportions
    final paid = controller.totalPayable * 4;
    final partial = controller.totalPayable;
    final overdue = controller.totalPayable * 1.5;
    final total = paid + partial + overdue;

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Payable Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              _SmallDropdown(label: 'This Month'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: [
                      PieChartSectionData(color: Colors.green, value: paid, title: '', radius: 25),
                      PieChartSectionData(color: Colors.orange, value: partial, title: '', radius: 25),
                      PieChartSectionData(color: Colors.red, value: overdue, title: '', radius: 25),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹ ').format(total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text('Total', style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SummaryLegend(label: 'Paid', amount: paid, color: Colors.green, percentage: (paid / total * 100)),
          const SizedBox(height: 8),
          _SummaryLegend(label: 'Partial', amount: partial, color: Colors.orange, percentage: (partial / total * 100)),
          const SizedBox(height: 8),
          _SummaryLegend(label: 'Overdue', amount: overdue, color: Colors.red, percentage: (overdue / total * 100)),
        ],
      ),
    );
  }
}

class _SummaryLegend extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final double percentage;

  const _SummaryLegend({required this.label, required this.amount, required this.color, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
        Text('${NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0).format(amount)} (${percentage.toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _TopSuppliersList extends StatelessWidget {
  const _TopSuppliersList();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Top Suppliers (By Purchase)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 12),
          _SupplierListItem(name: 'Sharma Traders', amount: 128450, color: Colors.purple),
          _SupplierListItem(name: 'Gupta Enterprises', amount: 98760, color: Colors.blue),
          _SupplierListItem(name: 'Vishal Marketing', amount: 85230, color: Colors.red),
          _SupplierListItem(name: 'R.K. Enterprises', amount: 76450, color: Colors.indigo),
          _SupplierListItem(name: 'Patel Distributors', amount: 64320, color: Colors.green),
        ],
      ),
    );
  }
}

class _SupplierListItem extends StatelessWidget {
  final String name;
  final double amount;
  final Color color;

  const _SupplierListItem({required this.name, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: color.withOpacity(0.1), child: Text(name.substring(0, 2).toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color))),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
          Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(amount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        ],
      ),
    );
  }
}

class _RecentPurchaseInvoicesList extends StatelessWidget {
  const _RecentPurchaseInvoicesList();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Recent Purchase Invoices', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 12),
          _InvoiceItem(no: 'PUR-10068', supplier: 'Sharma Traders', time: 'May 24, 2025', amount: 25680, status: 'Paid'),
          _InvoiceItem(no: 'PUR-10067', supplier: 'Gupta Enterprises', time: 'May 23, 2025', amount: 18750, status: 'Partial'),
          _InvoiceItem(no: 'PUR-10066', supplier: 'Vishal Marketing', time: 'May 22, 2025', amount: 32450, status: 'Paid'),
          _InvoiceItem(no: 'PUR-10065', supplier: 'R.K. Enterprises', time: 'May 21, 2025', amount: 14980, status: 'Due'),
          _InvoiceItem(no: 'PUR-10064', supplier: 'Patel Distributors', time: 'May 20, 2025', amount: 22600, status: 'Paid'),
        ],
      ),
    );
  }
}

class _InvoiceItem extends StatelessWidget {
  final String no, supplier, time, status;
  final double amount;
  const _InvoiceItem({required this.no, required this.supplier, required this.time, required this.amount, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;
    final statusColor = status == 'Paid' ? Colors.green : status == 'Partial' ? Colors.orange : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(no, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                Text(supplier, style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(time, style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(amount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor))),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallDropdown extends StatelessWidget {
  final String label;
  const _SmallDropdown({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: Row(children: [Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)), const Icon(Icons.keyboard_arrow_down_rounded, size: 14)]),
    );
  }
}
