import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../database/database.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/gst_controller.dart';

class GstView extends GetView<GstController> {
  const GstView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'GST / Tax',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1280;

          return Obx(() {
            if (controller.isLoading.value && controller.gstInvoices.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GstKpiGrid(width: width),
                  const SizedBox(height: 18),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _MainGstContent()),
                        const SizedBox(width: 18),
                        const Expanded(flex: 3, child: _GstRightRail()),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _MainGstContent(),
                        const SizedBox(height: 18),
                        const _GstRightRail(),
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

class _GstKpiGrid extends GetView<GstController> {
  final double width;

  const _GstKpiGrid({required this.width});

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
      _GstKpiData(
        title: 'Total Tax Collected',
        value: controller.totalTaxCollected.value,
        growth: 8.5,
        icon: Icons.account_balance_wallet_outlined,
        gradient: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
        sparkline: [25, 30, 28, 35, 32, 40, 38],
      ),
      _GstKpiData(
        title: 'Total Output Tax',
        value: controller.totalOutputTax,
        growth: 9.2,
        icon: Icons.upload_outlined,
        gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        sparkline: [20, 22, 25, 23, 28, 30, 35],
      ),
      _GstKpiData(
        title: 'Total Input Tax Credit',
        value: controller.totalInputTaxCredit,
        growth: 7.1,
        icon: Icons.download_outlined,
        gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        sparkline: [30, 28, 32, 35, 30, 38, 40],
      ),
      _GstKpiData(
        title: 'Net Tax Payable',
        value: controller.netTaxPayable,
        growth: -5.6,
        icon: Icons.payment_outlined,
        gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        sparkline: [40, 38, 35, 30, 25, 20, 15],
      ),
      _GstKpiData(
        title: 'Tax Liability',
        value: controller.taxLiability,
        subtitle: 'Due on Jun 20, 2025',
        icon: Icons.report_problem_outlined,
        gradient: [const Color(0xFFF43F5E), const Color(0xFFE11D48)],
        isAlert: true,
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
        mainAxisExtent: 190,
      ),
      itemBuilder: (context, index) {
        return _GstKpiCard(data: kpis[index])
            .animate()
            .fadeIn(delay: (70 * index).ms, duration: 420.ms)
            .slideY(begin: 0.14, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _GstKpiData {
  final String title;
  final double value;
  final double growth;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final List<double> sparkline;
  final bool isAlert;

  const _GstKpiData({
    required this.title,
    required this.value,
    this.growth = 0,
    this.subtitle = '',
    required this.icon,
    required this.gradient,
    this.sparkline = const [],
    this.isAlert = false,
  });
}

class _GstKpiCard extends StatelessWidget {
  final _GstKpiData data;

  const _GstKpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    if (data.isAlert) {
      return GlassPanel(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                const Spacer(),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(data.value),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(data.subtitle, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: muted)),
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: data.gradient.first, foregroundColor: Colors.white, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Prepare Return', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      );
    }

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
                      NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(data.value),
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
              if (data.sparkline.isNotEmpty)
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

class _MainGstContent extends GetView<GstController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: _ReturnSummaryPanel()),
            const SizedBox(width: 18),
            Expanded(flex: 5, child: _TaxLiabilityOverview()),
          ],
        ),
        const SizedBox(height: 18),
        GlassPanel(
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _GstTableFilterBar(),
              const SizedBox(height: 18),
              _GstTransactionsTable(),
              const SizedBox(height: 20),
              _TablePagination(),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: _HsnSummaryPanel()),
            const SizedBox(width: 18),
            Expanded(flex: 4, child: _TaxRateSummary()),
          ],
        ),
      ],
    );
  }
}

class _ReturnSummaryPanel extends GetView<GstController> {
  const _ReturnSummaryPanel();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Return Summary (GSTR)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              const _SmallDropdown(label: 'This Month'),
            ],
          ),
          const SizedBox(height: 18),
          _ReturnTabs(),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(color: Colors.green, value: 82, title: '', radius: 15),
                          PieChartSectionData(color: Colors.blue, value: 3.5, title: '', radius: 15),
                          PieChartSectionData(color: Colors.orange, value: 7.3, title: '', radius: 15),
                          PieChartSectionData(color: Colors.amber, value: 7.3, title: '', radius: 15),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Total Sales', style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.w700)),
                        Text(NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹ ').format(524860), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: const [
                    _TaxDetailRow(label: 'Taxable Value', value: '₹ 4,30,180.00', percentage: '82.0%', color: Colors.grey),
                    _TaxDetailRow(label: 'IGST', value: '₹ 18,560.00', percentage: '3.5%', color: Colors.blue),
                    _TaxDetailRow(label: 'CGST', value: '₹ 38,070.00', percentage: '7.3%', color: Colors.orange),
                    _TaxDetailRow(label: 'SGST', value: '₹ 38,070.00', percentage: '7.3%', color: Colors.amber),
                    _TaxDetailRow(label: 'Cess', value: '₹ 0.00', percentage: '0%', color: Colors.purple),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReturnTabs extends GetView<GstController> {
  const _ReturnTabs();
  @override
  Widget build(BuildContext context) {
    final tabs = ['GSTR-1', 'GSTR-3B', 'GSTR-9', 'GSTR-9C'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tabs.map((tab) {
        return Obx(() {
          final isSelected = controller.selectedTab.value == tab;
          return GestureDetector(
            onTap: () => controller.selectedTab.value = tab,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent, width: 2))),
              child: Text(tab, style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? const Color(0xFF4F46E5) : Colors.grey, fontSize: 12)),
            ),
          );
        });
      }).toList(),
    );
  }
}

class _TaxDetailRow extends StatelessWidget {
  final String label, value, percentage;
  final Color color;
  const _TaxDetailRow({required this.label, required this.value, required this.percentage, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey))),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          SizedBox(width: 32, child: Text('($percentage)', textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _TaxLiabilityOverview extends StatelessWidget {
  const _TaxLiabilityOverview();
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
              const Expanded(child: Text('Tax Liability Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              const _SmallDropdown(label: 'This Month'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              _LegendDot(color: Colors.blue, label: 'Output Tax'),
              SizedBox(width: 12),
              _LegendDot(color: Colors.indigo, label: 'Input Tax Credit'),
              SizedBox(width: 12),
              _LegendDot(color: Colors.purple, label: 'Net Tax Payable'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                maxY: 60,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}K', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, m) {
                        const months = ['Apr \'25', 'May \'25', 'Jun \'25 (MTD)'];
                        if (v.toInt() < months.length) return Text(months[v.toInt()], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey));
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barGroups: [
                  _BarGroup(0, [45, 15, 30]),
                  _BarGroup(1, [56, 18, 38]),
                  _BarGroup(2, [21, 8, 13]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _BarGroup(int x, List<double> values) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: values[0], color: Colors.blue, width: 8, borderRadius: BorderRadius.circular(2)),
        BarChartRodData(toY: values[1], color: Colors.indigo, width: 8, borderRadius: BorderRadius.circular(2)),
        BarChartRodData(toY: values[2], color: Colors.purple, width: 8, borderRadius: BorderRadius.circular(2)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey))]);
  }
}

class _GstTableFilterBar extends GetView<GstController> {
  const _GstTableFilterBar();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Row(
      children: [
        const Text('Tax Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(width: 24),
        Expanded(
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: muted, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => controller.searchQuery.value = v,
                    decoration: InputDecoration(
                      hintText: 'Search invoice no. or party...',
                      hintStyle: TextStyle(color: muted, fontSize: 12),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Icon(Icons.qr_code_scanner_rounded, color: muted, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        const _SmallFilterDropdown(label: 'All Types'),
        const SizedBox(width: 12),
        const _SmallFilterDropdown(label: 'All Status'),
        const SizedBox(width: 12),
        const _SmallFilterDropdown(label: 'Select Date', icon: Icons.calendar_today_outlined),
        const SizedBox(width: 12),
        const _IconActionButton(icon: Icons.tune_rounded),
      ],
    );
  }
}

class _SmallFilterDropdown extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _SmallFilterDropdown({required this.label, this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [if (icon != null) ...[Icon(icon, size: 14, color: Colors.grey), const SizedBox(width: 8)], Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)), const SizedBox(width: 6), const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Colors.grey)]),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  const _IconActionButton({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 16, color: Colors.grey),
    );
  }
}

class _GstTransactionsTable extends GetView<GstController> {
  const _GstTransactionsTable();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    final columns = ['Date', 'Type', 'Description', 'Taxable Value', 'IGST', 'CGST', 'SGST', 'Cess', 'Total Tax', 'Status', 'Action'];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9)))),
          child: Row(
            children: columns.map((col) {
              return Expanded(
                flex: col == 'Description' ? 3 : 2,
                child: Text(
                  col,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: muted),
                ),
              );
            }).toList(),
          ),
        ),
        Obx(() {
          final list = controller.filteredInvoices;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _GstRow(invoice: list[index]);
            },
          );
        }),
      ],
    );
  }
}

class _GstRow extends StatelessWidget {
  final Invoice invoice;
  const _GstRow({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;
    
    final status = invoice.status == 'PAID' ? 'Filed' : 'Claimed';
    final statusColor = invoice.status == 'PAID' ? Colors.green : Colors.blue;
    final type = invoice.id.contains('INV') ? 'Sales' : 'Purchase';
    final typeColor = type == 'Sales' ? Colors.green : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9)))),
      child: Row(
        children: [
          // Date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMM dd, yyyy').format(invoice.createdAt), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                Text(invoice.invoiceNumber, style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Type
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: typeColor)),
              ),
            ),
          ),
          // Description
          Expanded(flex: 3, child: const Text('Rahul Enterprises', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
          // Values
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(invoice.subtotal), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(invoice.igstTotal), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(invoice.cgstTotal), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(invoice.sgstTotal), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
          Expanded(flex: 2, child: const Text('₹ 0.00', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(invoice.taxTotal), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11))),
          // Status
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor)),
              ),
            ),
          ),
          // Action
          Expanded(
            flex: 2,
            child: Row(children: [IconButton(icon: const Icon(Icons.visibility_outlined, size: 16, color: Colors.grey), onPressed: () {}), IconButton(icon: const Icon(Icons.more_vert_rounded, size: 16, color: Colors.grey), onPressed: () {})]),
          ),
        ],
      ),
    );
  }
}

class _TablePagination extends StatelessWidget {
  const _TablePagination();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Showing 1 to 5 of 125 entries', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
        const Spacer(),
        const _PaginationButton(icon: Icons.chevron_left_rounded),
        const SizedBox(width: 6),
        const _PageNumber(number: 1, active: true),
        const _PageNumber(number: 2),
        const _PageNumber(number: 3),
        const _PageNumber(number: 4),
        const _PageNumber(number: 5),
        const Text('...', style: TextStyle(color: Colors.grey, fontSize: 10)),
        const _PageNumber(number: 25),
        const SizedBox(width: 6),
        const _PaginationButton(icon: Icons.chevron_right_rounded),
        const Spacer(),
        const Text('Rows per page:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(6)),
          child: Row(children: const [Text('10', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)), SizedBox(width: 4), Icon(Icons.keyboard_arrow_down_rounded, size: 14)]),
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
      width: 28, height: 28,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, size: 16, color: Colors.grey),
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
      width: 28, height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(color: active ? const Color(0xFF4F46E5) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
      child: Center(child: Text('$number', style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.w800, fontSize: 10))),
    );
  }
}

class _HsnSummaryPanel extends StatelessWidget {
  const _HsnSummaryPanel();
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
              const Expanded(child: Text('HSN Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              const _SmallDropdown(label: 'This Month'),
            ],
          ),
          const SizedBox(height: 18),
          const _HsnTableHeader(),
          const _HsnRow(hsn: '84713010', desc: 'Laptop Computers', taxable: 145600, igst: 7280, cgst: 6552, sgst: 6552, total: 20384),
          const _HsnRow(hsn: '85235110', desc: 'Mobile Phones', taxable: 102450, igst: 5122.5, cgst: 4610.25, sgst: 4610.25, total: 14343),
          const _HsnRow(hsn: '85171290', desc: 'Accessories', taxable: 65980, igst: 0, cgst: 2969.1, sgst: 2969.1, total: 5938.2),
          const _HsnRow(hsn: '85287100', desc: 'Pen Drives', taxable: 28750, igst: 0, cgst: 1293.75, sgst: 1293.75, total: 2587.5),
          const _HsnRow(hsn: 'Other HSN', desc: 'Other Items', taxable: 101080, igst: 6158.5, cgst: 4548, sgst: 4548, total: 15254.5),
        ],
      ),
    );
  }
}

class _HsnTableHeader extends StatelessWidget {
  const _HsnTableHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1)))),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('HSN Code', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
          Expanded(flex: 3, child: Text('Description', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
          Expanded(flex: 2, child: Text('Taxable Value', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
          Expanded(flex: 1, child: Text('IGST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
          Expanded(flex: 1, child: Text('CGST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
          Expanded(flex: 1, child: Text('SGST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
          Expanded(flex: 2, child: Text('Total Tax', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
        ],
      ),
    );
  }
}

class _HsnRow extends StatelessWidget {
  final String hsn, desc;
  final double taxable, igst, cgst, sgst, total;
  const _HsnRow({required this.hsn, required this.desc, required this.taxable, required this.igst, required this.cgst, required this.sgst, required this.total});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(hsn, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
          Expanded(flex: 3, child: Text(desc, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey))),
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(taxable), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
          Expanded(flex: 1, child: Text(igst > 0 ? NumberFormat.compact().format(igst) : '-', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
          Expanded(flex: 1, child: Text(cgst > 0 ? NumberFormat.compact().format(cgst) : '-', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
          Expanded(flex: 1, child: Text(sgst > 0 ? NumberFormat.compact().format(sgst) : '-', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(total), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

class _TaxRateSummary extends GetView<GstController> {
  const _TaxRateSummary();
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
              const Expanded(child: Text('Tax Rate Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              const _SmallDropdown(label: 'This Month'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(color: Colors.blue, value: 55.6, title: '', radius: 15),
                      PieChartSectionData(color: Colors.teal, value: 24, title: '', radius: 15),
                      PieChartSectionData(color: Colors.orange, value: 12, title: '', radius: 15),
                      PieChartSectionData(color: Colors.grey, value: 8.4, title: '', radius: 15),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total Tax', style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.w700)),
                    Text(NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹ ').format(controller.totalTaxCollected.value), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _TaxRateRow(label: '18%', amount: '₹ 52,640.00', percentage: '55.6%', color: Colors.blue),
          const _TaxRateRow(label: '12%', amount: '₹ 22,780.00', percentage: '24.0%', color: Colors.teal),
          const _TaxRateRow(label: '5%', amount: '₹ 11,420.00', percentage: '12.0%', color: Colors.orange),
          const _TaxRateRow(label: '0% / Exempt', amount: '₹ 7,840.00', percentage: '8.4%', color: Colors.grey),
        ],
      ),
    );
  }
}

class _TaxRateRow extends StatelessWidget {
  final String label, amount, percentage;
  final Color color;
  const _TaxRateRow({required this.label, required this.amount, required this.percentage, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey))),
          Text(amount, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          SizedBox(width: 40, child: Text('($percentage)', textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _GstRightRail extends StatelessWidget {
  const _GstRightRail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _UpcomingDueDates(),
        SizedBox(height: 18),
        _GstinDetailsCard(),
        SizedBox(height: 18),
        _GstQuickActions(),
      ],
    );
  }
}

class _UpcomingDueDates extends StatelessWidget {
  const _UpcomingDueDates();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Upcoming Due Dates', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 18),
          const _DueDateItem(label: 'GSTR-1', date: 'May 11, 2025', status: 'Filed', color: Colors.green),
          const _DueDateItem(label: 'GSTR-3B', date: 'May 20, 2025', status: 'Due in 3 days', color: Colors.orange),
          const _DueDateItem(label: 'GSTR-4 (Quarterly)', date: 'Jun 30, 2025', status: 'Due in 44 days', color: Colors.orange),
          const _DueDateItem(label: 'GSTR-9 (Annual)', date: 'Dec 31, 2025', status: 'Due in 220 days', color: Colors.blue),
        ],
      ),
    );
  }
}

class _DueDateItem extends StatelessWidget {
  final String label, date, status;
  final Color color;
  const _DueDateItem({required this.label, required this.date, required this.status, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.calendar_today_outlined, size: 16, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(6)), child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color))),
        ],
      ),
    );
  }
}

class _GstinDetailsCard extends StatelessWidget {
  const _GstinDetailsCard();

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
              const Expanded(child: Text('GSTIN Details', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton(onPressed: () {}, child: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.assignment_ind_outlined, size: 32, color: Color(0xFF6366F1)),
            ),
          ),
          const SizedBox(height: 18),
          const _DetailRow(label: 'GSTIN', value: '27ABCDE1234F1Z5'),
          const _DetailRow(label: 'Trade Name', value: 'Main Store'),
          const _DetailRow(label: 'Legal Name', value: 'Printonex Technologies Pvt. Ltd.'),
          const _DetailRow(label: 'State', value: 'Maharashtra (27)'),
          const _DetailRow(label: 'Type', value: 'Regular'),
          const _DetailRow(label: 'Registration Date', value: '01 Jul, 2022'),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)),
          Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _GstQuickActions extends StatelessWidget {
  const _GstQuickActions();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: const [
              _QuickActionBtn(label: 'Prepare GSTR-1', icon: Icons.description_outlined, color: Colors.green),
              _QuickActionBtn(label: 'Prepare GSTR-3B', icon: Icons.description_outlined, color: Colors.blue),
              _QuickActionBtn(label: 'Import Sales', icon: Icons.upload_file_outlined, color: Colors.purple),
              _QuickActionBtn(label: 'Import Purchases', icon: Icons.download_for_offline_outlined, color: Colors.orange),
              _QuickActionBtn(label: 'Tax Liability', icon: Icons.calculate_outlined, color: Colors.pink),
              _QuickActionBtn(label: 'GST Reconciliation', icon: Icons.sync_rounded, color: Colors.teal),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _QuickActionBtn({required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, height: 1.2)),
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
