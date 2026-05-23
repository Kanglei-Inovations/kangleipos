import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../database/database.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Reports',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1280;

          return Obx(() {
            if (controller.isLoading.value && controller.recentSales.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Sidebar: Categories
                    if (isDesktop)
                      const SizedBox(width: 240, child: _ReportCategoriesSidebar()),
                    if (isDesktop) const SizedBox(width: 18),
                    
                    // Main Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ReportsKpiGrid(width: width - (isDesktop ? 260 : 0)),
                          const SizedBox(height: 18),
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 6, child: _SalesOverviewChart()),
                                const SizedBox(width: 18),
                                Expanded(flex: 4, child: _TopProductsTable()),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _SalesOverviewChart(),
                                const SizedBox(height: 18),
                                _TopProductsTable(),
                              ],
                            ),
                          const SizedBox(height: 18),
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _ProfitLossOverview()),
                                const SizedBox(width: 18),
                                Expanded(flex: 3, child: _SalesByCategoryChart()),
                                const SizedBox(width: 18),
                                Expanded(flex: 4, child: _RecentReportsPanel()),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _ProfitLossOverview(),
                                const SizedBox(height: 18),
                                _SalesByCategoryChart(),
                                const SizedBox(height: 18),
                                _RecentReportsPanel(),
                              ],
                            ),
                          const SizedBox(height: 18),
                          _ReportSettingsPanel(),
                        ],
                      ),
                    ),
                    
                    // Right Sidebar: Quick Reports
                    if (isDesktop) const SizedBox(width: 18),
                    if (isDesktop)
                      const SizedBox(width: 280, child: _QuickReportsRail()),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _ReportCategoriesSidebar extends GetView<ReportsController> {
  const _ReportCategoriesSidebar();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': 'All Reports', 'icon': Icons.description_outlined},
      {'label': 'Sales Reports', 'icon': Icons.point_of_sale_outlined},
      {'label': 'Purchase Reports', 'icon': Icons.shopping_bag_outlined},
      {'label': 'Inventory Reports', 'icon': Icons.inventory_2_outlined},
      {'label': 'GST Reports', 'icon': Icons.account_balance_outlined},
      {'label': 'Financial Reports', 'icon': Icons.analytics_outlined},
      {'label': 'Customer Reports', 'icon': Icons.people_outline},
      {'label': 'Supplier Reports', 'icon': Icons.local_shipping_outlined},
      {'label': 'Expense Reports', 'icon': Icons.account_balance_wallet_outlined},
      {'label': 'Tax Reports', 'icon': Icons.receipt_long_outlined},
      {'label': 'Profit & Loss', 'icon': Icons.trending_up_rounded},
      {'label': 'Stock Reports', 'icon': Icons.storage_outlined},
    ];

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Report Categories', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          const SizedBox(height: 12),
          ...categories.map((cat) {
            return Obx(() {
              final isSelected = controller.selectedCategory.value == cat['label'];
              return InkWell(
                onTap: () => controller.selectedCategory.value = cat['label'] as String,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4F46E5).withOpacity(0.1) : Colors.transparent,
                    border: Border(right: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent, width: 3)),
                  ),
                  child: Row(
                    children: [
                      Icon(cat['icon'] as IconData, size: 18, color: isSelected ? const Color(0xFF4F46E5) : Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat['label'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? const Color(0xFF4F46E5) : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          }),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.withOpacity(0.1))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Custom Report', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('Create custom reports as per your business needs.', style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.4)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF4F46E5), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFF4F46E5), width: 1))),
                      child: const Text('+ Create Custom Report', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportsKpiGrid extends GetView<ReportsController> {
  final double width;

  const _ReportsKpiGrid({required this.width});

  @override
  Widget build(BuildContext context) {
    final columns = width >= 1100
        ? 5
        : width >= 800
            ? 3
            : 2;

    final kpis = [
      _ReportKpiData(
        title: 'Total Sales',
        value: controller.totalSales.value,
        growth: 12.8,
        icon: Icons.point_of_sale_outlined,
        gradient: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
        sparkline: [25, 30, 28, 35, 32, 40, 38],
      ),
      _ReportKpiData(
        title: 'Total Purchases',
        value: controller.totalPurchases.value,
        growth: 10.7,
        icon: Icons.shopping_bag_outlined,
        gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        sparkline: [20, 22, 25, 23, 28, 30, 35],
      ),
      _ReportKpiData(
        title: 'Gross Profit',
        value: controller.grossProfit.value,
        growth: 14.3,
        icon: Icons.trending_up_rounded,
        gradient: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
        sparkline: [30, 28, 32, 35, 30, 38, 40],
      ),
      _ReportKpiData(
        title: 'Total Expenses',
        value: controller.totalExpenses.value,
        growth: 8.5,
        icon: Icons.account_balance_wallet_outlined,
        gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        sparkline: [40, 38, 35, 30, 25, 20, 15],
      ),
      _ReportKpiData(
        title: 'Net Profit',
        value: controller.netProfit.value,
        growth: 15.6,
        icon: Icons.account_balance_outlined,
        gradient: [const Color(0xFFF43F5E), const Color(0xFFE11D48)],
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
        mainAxisExtent: 180,
      ),
      itemBuilder: (context, index) {
        return _ReportKpiCard(data: kpis[index])
            .animate()
            .fadeIn(delay: (70 * index).ms, duration: 420.ms)
            .slideY(begin: 0.14, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _ReportKpiData {
  final String title;
  final double value;
  final double growth;
  final IconData icon;
  final List<Color> gradient;
  final List<double> sparkline;

  const _ReportKpiData({
    required this.title,
    required this.value,
    required this.growth,
    required this.icon,
    required this.gradient,
    required this.sparkline,
  });
}

class _ReportKpiCard extends StatelessWidget {
  final _ReportKpiData data;

  const _ReportKpiCard({required this.data});

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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(data.value),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_upward_rounded, size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            '${data.growth}%',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w800, fontSize: 11),
                          ),
                          const SizedBox(width: 4),
                          Text('vs last period', style: TextStyle(color: muted, fontSize: 9)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (data.sparkline.isNotEmpty) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  height: 24,
                  child: CustomPaint(
                    painter: _KpiSparklinePainter(points: data.sparkline, color: data.gradient.first),
                  ),
                ),
              ],
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

class _SalesOverviewChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Sales Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              const _SmallDropdown(label: 'This Month'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              _LegendDot(color: Colors.blue, label: 'Sales (₹)'),
              SizedBox(width: 16),
              _LegendDot(color: Colors.green, label: 'Orders'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 1, maxX: 31, minY: 0, maxY: 100,
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 50,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 20,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}K', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 4,
                      getTitlesWidget: (v, m) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(v.toInt() == 1 ? '01 May' : v.toInt() < 10 ? '0${v.toInt()} May' : '${v.toInt()} May', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(1, 40), FlSpot(5, 55), FlSpot(9, 48), FlSpot(13, 65), FlSpot(17, 60), FlSpot(21, 75), FlSpot(24, 70)],
                    isCurved: true, color: Colors.blue, barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.05)),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(1, 20), FlSpot(5, 35), FlSpot(9, 30), FlSpot(13, 45), FlSpot(17, 40), FlSpot(21, 55), FlSpot(24, 50)],
                    isCurved: true, color: Colors.green, barWidth: 2, dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey))]);
  }
}

class _TopProductsTable extends StatelessWidget {
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
              const Expanded(child: Text('Top Products by Sales', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              const _SmallDropdown(label: 'This Month'),
              const SizedBox(width: 8),
              const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              SizedBox(width: 20, child: Text('#', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 4, child: Text('Product', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 2, child: Text('Qty Sold', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 3, child: Text('Revenue', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
            ],
          ),
          const SizedBox(height: 12),
          const _TopProductRow(index: 1, name: 'iPhone 15 Pro Max', qty: 32, revenue: 256000),
          const _TopProductRow(index: 2, name: 'Samsung Galaxy S24', qty: 28, revenue: 167440),
          const _TopProductRow(index: 3, name: 'Noise Air Buds', qty: 45, revenue: 67500),
          const _TopProductRow(index: 4, name: 'Boat Rockerz 450', qty: 38, revenue: 45600),
          const _TopProductRow(index: 5, name: 'HP Laptop 15s', qty: 12, revenue: 36000),
        ],
      ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  final int index;
  final String name;
  final int qty;
  final double revenue;
  const _TopProductRow({required this.index, required this.name, required this.qty, required this.revenue});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(width: 20, child: Text('$index', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey))),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.image_outlined, size: 16, color: Colors.grey)),
                const SizedBox(width: 10),
                Expanded(child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text('$qty', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
          Expanded(flex: 3, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(revenue), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _ProfitLossOverview extends GetView<ReportsController> {
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
              const Expanded(child: Text('Profit & Loss Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              const _SmallDropdown(label: 'This Month'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2, centerSpaceRadius: 45,
                    sections: [
                      PieChartSectionData(color: Colors.blue, value: 100, title: '', radius: 15),
                      PieChartSectionData(color: Colors.green, value: 60, title: '', radius: 15),
                      PieChartSectionData(color: Colors.orange, value: 20, title: '', radius: 15),
                      PieChartSectionData(color: Colors.purple, value: 30, title: '', radius: 15),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Net Profit', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w700)),
                    Text(NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹ ').format(controller.netProfit.value), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _ChartLegendRow(label: 'Total Revenue', value: controller.totalSales.value, color: Colors.blue),
          _ChartLegendRow(label: 'Total Cost of Goods Sold', value: controller.totalSales.value * 0.6, color: Colors.green),
          _ChartLegendRow(label: 'Total Expenses', value: controller.totalExpenses.value, color: Colors.orange),
          _ChartLegendRow(label: 'Net Profit', value: controller.netProfit.value, color: Colors.purple),
        ],
      ),
    );
  }
}

class _ChartLegendRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _ChartLegendRow({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey))),
          Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(value), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SalesByCategoryChart extends GetView<ReportsController> {
  @override
  Widget build(BuildContext context) {
    final colors = [Colors.blue, Colors.indigo, Colors.orange, Colors.amber, Colors.grey];
    final data = controller.salesByCategory;

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Sales by Category', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              const _SmallDropdown(label: 'This Month'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0, centerSpaceRadius: 45,
                    sections: data.entries.indexed.map((e) {
                      return PieChartSectionData(color: colors[e.$1 % colors.length], value: e.$2.value, title: '', radius: 25);
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w700)),
                    Text(NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹ ').format(controller.totalSales.value), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...data.entries.indexed.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[e.$1 % colors.length], borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.$2.key, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                  Text('${e.$2.value.toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RecentReportsPanel extends StatelessWidget {
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
              const Expanded(child: Text('Recent Generated Reports', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              const _HeaderButton(label: 'View All Reports', icon: Icons.description_outlined, color: Colors.transparent),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(flex: 3, child: Text('Report Name', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 1, child: Text('Type', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 2, child: Text('Generated On', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              SizedBox(width: 40, child: Text('Action', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
            ],
          ),
          const SizedBox(height: 12),
          const _RecentReportRow(name: 'Sales Report - May 2025', type: 'Sales', date: 'May 24, 2025 11:30 AM'),
          const _RecentReportRow(name: 'Purchase Report - May 2025', type: 'Purchase', date: 'May 24, 2025 11:25 AM'),
          const _RecentReportRow(name: 'GST Summary - May 2025', type: 'GST', date: 'May 24, 2025 11:20 AM'),
          const _RecentReportRow(name: 'Profit & Loss - May 2025', type: 'P&L', date: 'May 24, 2025 11:15 AM'),
          const _RecentReportRow(name: 'Stock Report - May 2025', type: 'Stock', date: 'May 24, 2025 11:10 AM'),
        ],
      ),
    );
  }
}

class _RecentReportRow extends StatelessWidget {
  final String name, type, date;
  const _RecentReportRow({required this.name, required this.type, required this.date});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
          Expanded(flex: 1, child: Text(type, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
          Expanded(flex: 2, child: Text(date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
          SizedBox(width: 40, child: Icon(Icons.download_rounded, size: 16, color: Colors.blue.withOpacity(0.8))),
        ],
      ),
    );
  }
}

class _QuickReportsRail extends StatelessWidget {
  const _QuickReportsRail();

  @override
  Widget build(BuildContext context) {
    final quickReports = [
      {'label': 'Sales Report', 'icon': Icons.point_of_sale_outlined, 'color': Colors.blue},
      {'label': 'Purchase Report', 'icon': Icons.shopping_bag_outlined, 'color': Colors.green},
      {'label': 'GST Summary', 'icon': Icons.account_balance_outlined, 'color': Colors.teal},
      {'label': 'Profit & Loss', 'icon': Icons.trending_up_rounded, 'color': Colors.red},
      {'label': 'Stock Report', 'icon': Icons.storage_outlined, 'color': Colors.orange},
      {'label': 'Customer Ledger', 'icon': Icons.people_outline, 'color': Colors.purple},
      {'label': 'Supplier Ledger', 'icon': Icons.local_shipping_outlined, 'color': Colors.indigo},
      {'label': 'Tax Report', 'icon': Icons.receipt_long_outlined, 'color': Colors.green},
      {'label': 'Expense Report', 'icon': Icons.account_balance_wallet_outlined, 'color': Colors.blue},
    ];

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Quick Reports', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 20),
          ...quickReports.map((report) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: (report['color'] as Color).withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: (report['color'] as Color).withOpacity(0.1))),
                child: Row(
                  children: [
                    Icon(report['icon'] as IconData, size: 18, color: report['color'] as Color),
                    const SizedBox(width: 12),
                    Expanded(child: Text(report['label'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ReportSettingsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Report Settings', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                SizedBox(height: 4),
                Text('Configure report preferences and export settings', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Date Format', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                SizedBox(height: 8),
                _SmallDropdown(label: 'DD MMM YYYY'),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Currency', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                SizedBox(height: 8),
                _SmallDropdown(label: 'INR (₹)'),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Export Format', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    _ExportToggle(icon: Icons.picture_as_pdf_outlined, label: 'PDF', active: true),
                    SizedBox(width: 8),
                    _ExportToggle(icon: Icons.table_chart_outlined, label: 'Excel'),
                    SizedBox(width: 8),
                    _ExportToggle(icon: Icons.description_outlined, label: 'CSV'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, size: 16),
            label: const Text('Manage Settings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final bool isPrimary;

  const _HeaderButton({required this.label, required this.icon, this.color, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isPrimary ? (color ?? const Color(0xFF4F46E5)) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isPrimary ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isPrimary ? Colors.white : Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: isPrimary ? Colors.white : Colors.black, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ExportToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _ExportToggle({required this.icon, required this.label, this.active = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: active ? Colors.red.withOpacity(0.05) : Colors.transparent, border: Border.all(color: active ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [Icon(icon, size: 14, color: active ? Colors.red : Colors.grey), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: active ? Colors.red : Colors.grey))]),
    );
  }
}

class _SmallDropdown extends StatelessWidget {
  final String label;
  const _SmallDropdown({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey)]),
    );
  }
}
