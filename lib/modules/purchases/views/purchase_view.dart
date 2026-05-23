import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../database/database.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/purchase_controller.dart';

class PurchaseView extends GetView<PurchaseController> {
  const PurchaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Purchases',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1280;

          return Obx(() {
            if (controller.isLoading.value && controller.purchaseHistory.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PurchaseKpiGrid(width: width),
                  const SizedBox(height: 18),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _MainPurchaseContent()),
                        const SizedBox(width: 18),
                        const SizedBox(width: 330, child: _PurchaseRightRail()),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _MainPurchaseContent(),
                        const SizedBox(height: 18),
                        const _PurchaseRightRail(),
                      ],
                    ),
                  const SizedBox(height: 18),
                  _BottomActionButtons(),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}

class _PurchaseKpiGrid extends GetView<PurchaseController> {
  final double width;

  const _PurchaseKpiGrid({required this.width});

  @override
  Widget build(BuildContext context) {
    final columns = width >= 1180
        ? 4
        : width >= 860
            ? 2
            : 1;

    final kpis = [
      _PurchaseKpiData(
        title: 'Total Purchases',
        value: controller.totalPurchases,
        growth: 12.8,
        icon: Icons.shopping_cart_outlined,
        gradient: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
        sparkline: [25, 30, 28, 35, 32, 40, 38],
      ),
      _PurchaseKpiData(
        title: 'Total Paid',
        value: controller.totalPaid,
        growth: 9.7,
        icon: Icons.account_balance_wallet_outlined,
        gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        sparkline: [20, 22, 25, 23, 28, 30, 35],
      ),
      _PurchaseKpiData(
        title: 'Total Due',
        value: controller.totalDue,
        growth: -8.4,
        icon: Icons.lock_outline,
        gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        sparkline: [40, 38, 35, 30, 25, 20, 15],
      ),
      _PurchaseKpiData(
        title: 'Total Invoices',
        value: controller.totalInvoices.toDouble(),
        growth: 5.2,
        icon: Icons.description_outlined,
        gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        sparkline: [10, 12, 11, 14, 13, 16, 15],
        isCurrency: false,
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
        return _PurchaseKpiCard(data: kpis[index])
            .animate()
            .fadeIn(delay: (70 * index).ms, duration: 420.ms)
            .slideY(begin: 0.14, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _PurchaseKpiData {
  final String title;
  final double value;
  final double growth;
  final IconData icon;
  final List<Color> gradient;
  final List<double> sparkline;
  final bool isCurrency;

  const _PurchaseKpiData({
    required this.title,
    required this.value,
    required this.growth,
    required this.icon,
    required this.gradient,
    required this.sparkline,
    this.isCurrency = true,
  });
}

class _PurchaseKpiCard extends StatelessWidget {
  final _PurchaseKpiData data;

  const _PurchaseKpiCard({required this.data});

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

class _MainPurchaseContent extends GetView<PurchaseController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PurchaseTabs(),
        const SizedBox(height: 18),
        _PurchaseFilterBar(),
        const SizedBox(height: 18),
        _PurchaseTable(),
      ],
    );
  }
}

class _PurchaseTabs extends GetView<PurchaseController> {
  @override
  Widget build(BuildContext context) {
    final tabs = ['All Purchases', 'Purchase Orders', 'GRN / Receive Notes', 'Returns', 'Bills'];

    return Row(
      children: tabs.map((tab) {
        return Obx(() {
          final isSelected = controller.selectedTab.value == tab;
          return GestureDetector(
            onTap: () => controller.selectedTab.value = tab,
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? const Color(0xFF4F46E5) : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }
}

class _PurchaseFilterBar extends GetView<PurchaseController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: muted, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (v) => controller.searchQuery.value = v,
                    decoration: InputDecoration(
                      hintText: 'Search by invoice no., supplier...',
                      hintStyle: TextStyle(color: muted, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Icon(Icons.qr_code_scanner_rounded, color: muted, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _FilterDropdown(label: 'All Suppliers', icon: Icons.person_outline),
        const SizedBox(width: 12),
        _FilterDropdown(label: 'All Status', icon: Icons.sync_rounded),
        const SizedBox(width: 12),
        _FilterDropdown(label: 'Select Date', icon: Icons.calendar_today_outlined),
        const SizedBox(width: 12),
        _ActionButton(icon: Icons.tune_rounded, label: 'Filters'),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FilterDropdown({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: muted),
        ],
      ),
    );
  }
}

class _PurchaseTable extends GetView<PurchaseController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    final columns = ['Invoice No.', 'Supplier', 'Date', 'Total Amount', 'Paid Amount', 'Due Amount', 'Status', 'Actions'];

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: columns.map((col) {
                return Expanded(
                  flex: col == 'Supplier' ? 3 : 2,
                  child: Text(
                    col,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: muted),
                  ),
                );
              }).toList(),
            ),
          ),
          Obx(() {
            final purchases = controller.filteredPurchases;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                return _PurchaseRow(purchase: purchases[index]);
              },
            );
          }),
          _TablePagination(),
        ],
      ),
    );
  }
}

class _PurchaseRow extends GetView<PurchaseController> {
  final Purchase purchase;

  const _PurchaseRow({required this.purchase});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;
    final supplier = controller.suppliers.firstWhereOrNull((s) => s.id == purchase.supplierId);
    
    final paidAmount = purchase.grandTotal * 0.8; // Mock
    final dueAmount = purchase.grandTotal - paidAmount;
    final status = dueAmount == 0 ? 'Paid' : dueAmount < purchase.grandTotal ? 'Partial' : 'Due';
    final statusColor = status == 'Paid' ? Colors.green : status == 'Partial' ? Colors.orange : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          // Invoice No
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(purchase.purchaseNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text('Bill', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Supplier
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Text(supplier?.name.substring(0, 1).toUpperCase() ?? 'S', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(supplier?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      Text(supplier?.address?.split(',').first ?? 'No Address', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMM dd, yyyy').format(purchase.purchaseDate), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(DateFormat('hh:mm a').format(purchase.purchaseDate), style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Total Amount
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(purchase.grandTotal), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
          // Paid Amount
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(paidAmount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.green))),
          // Due Amount
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(dueAmount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.red))),
          // Status
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor), textAlign: TextAlign.center),
            ),
          ),
          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _TableActionIcon(icon: Icons.visibility_outlined),
                _TableActionIcon(icon: Icons.print_outlined),
                _TableActionIcon(icon: Icons.more_vert_rounded),
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
  const _TableActionIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: Colors.grey),
    );
  }
}

class _TablePagination extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _PaginationButton(icon: Icons.chevron_left_rounded),
          const SizedBox(width: 8),
          _PageNumber(number: 1, active: true),
          _PageNumber(number: 2),
          _PageNumber(number: 3),
          _PageNumber(number: 4),
          _PageNumber(number: 5),
          const Text('...', style: TextStyle(color: Colors.grey)),
          _PageNumber(number: 9),
          const SizedBox(width: 8),
          _PaginationButton(icon: Icons.chevron_right_rounded),
          const Spacer(),
          const Text('Rows per page:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
            child: Row(children: const [Text('10', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)), SizedBox(width: 8), Icon(Icons.keyboard_arrow_down_rounded, size: 16)]),
          ),
        ],
      ),
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

class _PurchaseRightRail extends StatelessWidget {
  const _PurchaseRightRail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _PurchaseSummaryChart(),
        SizedBox(height: 18),
        _TopSuppliersList(),
        SizedBox(height: 18),
        _RecentGrnList(),
      ],
    );
  }
}

class _PurchaseSummaryChart extends GetView<PurchaseController> {
  const _PurchaseSummaryChart();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;
    
    final data = controller.purchaseSummaryData;

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Purchase Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
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
                      PieChartSectionData(color: Colors.green, value: data['Paid']!, title: '', radius: 25),
                      PieChartSectionData(color: Colors.orange, value: data['Partial']!, title: '', radius: 25),
                      PieChartSectionData(color: Colors.red, value: data['Due']!, title: '', radius: 25),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹ ').format(controller.totalPurchases), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text('Total', style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SummaryLegend(label: 'Paid', amount: data['Paid']!, color: Colors.green, percentage: 79.8),
          const SizedBox(height: 8),
          _SummaryLegend(label: 'Partial', amount: data['Partial']!, color: Colors.orange, percentage: 10.4),
          const SizedBox(height: 8),
          _SummaryLegend(label: 'Due', amount: data['Due']!, color: Colors.red, percentage: 9.8),
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
        Text('${NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0).format(amount)} ($percentage%)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _TopSuppliersList extends GetView<PurchaseController> {
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
              const Expanded(child: Text('Top Suppliers', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 12),
          _SupplierListItem(name: 'Sharma Traders', amount: 75680, growth: 12.4, color: Colors.red),
          _SupplierListItem(name: 'Vishal Marketing', amount: 65450, growth: 8.6, color: Colors.purple),
          _SupplierListItem(name: 'Gupta Traders', amount: 48750, growth: 5.3, color: Colors.blue),
          _SupplierListItem(name: 'R.K. Enterprises', amount: 39860, growth: 3.7, color: Colors.indigo),
          _SupplierListItem(name: 'Amit & Brothers', amount: 32600, growth: 2.1, color: Colors.green),
        ],
      ),
    );
  }
}

class _SupplierListItem extends StatelessWidget {
  final String name;
  final double amount;
  final double growth;
  final Color color;

  const _SupplierListItem({required this.name, required this.amount, required this.growth, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: color.withOpacity(0.1), child: Text(name.substring(0, 1), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color))),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0).format(amount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              Row(children: [Icon(Icons.arrow_upward_rounded, size: 10, color: Colors.green), Text('$growth%', style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))]),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentGrnList extends StatelessWidget {
  const _RecentGrnList();

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
              const Expanded(child: Text('Recent GRN / Receipts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 12),
          _GrnItem(no: 'GRN-10045', supplier: 'Sharma Traders', time: '24 May, 11:45 AM', status: 'Received'),
          _GrnItem(no: 'GRN-10044', supplier: 'Gupta Traders', time: '23 May, 04:20 PM', status: 'Received'),
          _GrnItem(no: 'GRN-10043', supplier: 'R.K. Enterprises', time: '22 May, 02:10 PM', status: 'Received'),
          _GrnItem(no: 'GRN-10042', supplier: 'Vishal Marketing', time: '21 May, 10:30 AM', status: 'Received'),
        ],
      ),
    );
  }
}

class _GrnItem extends StatelessWidget {
  final String no, supplier, time, status;
  const _GrnItem({required this.no, required this.supplier, required this.time, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

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
              Text(time, style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('Received', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green))),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BigActionButton(label: 'New Purchase', icon: Icons.add_rounded, color: const Color(0xFF4F46E5), isPrimary: true),
        const SizedBox(width: 12),
        _BigActionButton(label: 'Purchase Order', icon: Icons.assignment_outlined),
        const SizedBox(width: 12),
        _BigActionButton(label: 'GRN / Receive', icon: Icons.download_done_rounded),
        const SizedBox(width: 12),
        _BigActionButton(label: 'Purchase Return', icon: Icons.keyboard_return_rounded, isRed: true),
        const SizedBox(width: 12),
        _BigActionButton(label: 'Import', icon: Icons.upload_file_rounded),
      ],
    );
  }
}

class _BigActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final bool isPrimary;
  final bool isRed;

  const _BigActionButton({required this.label, required this.icon, this.color, this.isPrimary = false, this.isRed = false});

  @override
  Widget build(BuildContext context) {
    final bgColor = isPrimary ? (color ?? const Color(0xFF4F46E5)) : isRed ? Colors.red.withOpacity(0.05) : Colors.white;
    final textColor = isPrimary ? Colors.white : isRed ? Colors.red : const Color(0xFF4F46E5);
    final borderColor = isPrimary ? Colors.transparent : isRed ? Colors.red.withOpacity(0.1) : const Color(0xFFE2E8F0);

    return Expanded(
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: textColor, fontSize: 13)),
          ],
        ),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Container(
      height: 44,
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
