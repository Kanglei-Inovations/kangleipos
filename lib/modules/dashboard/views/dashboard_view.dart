import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Dashboard',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1280;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: isDesktop
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _MainDashboardColumn(width: width - 348)),
                const SizedBox(width: 18),
                const SizedBox(width: 330, child: _RightRail()),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MainDashboardColumn(width: width),
                const SizedBox(height: 18),
                const _RightRail(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MainDashboardColumn extends StatelessWidget {
  final double width;

  const _MainDashboardColumn({required this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _KpiGrid(width: width),
        const SizedBox(height: 18),
        _ChartsSection(width: width),
        const SizedBox(height: 18),
        _OperationsSection(width: width),
        const SizedBox(height: 18),
        const _BottomStatusBar(),
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final double width;

  const _KpiGrid({required this.width});

  @override
  Widget build(BuildContext context) {
    final columns = width >= 1180
        ? 5
        : width >= 860
        ? 3
        : width >= 560
        ? 2
        : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _kpis.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 180,
      ),
      itemBuilder: (context, index) {
        return _KpiCard(data: _kpis[index], index: index)
            .animate()
            .fadeIn(delay: (70 * index).ms, duration: 420.ms)
            .slideY(begin: 0.14, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  final int index;

  const _KpiCard({
    required this.data,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted =
    isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return _HoverLift(
      child: GlassPanel(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(16),
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.62)
            : Colors.white.withValues(alpha: 0.76),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: data.gradient),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: data.gradient.last.withValues(alpha: 0.30),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AnimatedMetricValue(data: data),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  data.growth >= 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: data.growth >= 0
                      ? AppTheme.successColor
                      : AppTheme.dangerColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${data.growth.abs().toStringAsFixed(1)}% vs yesterday',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: data.growth >= 0
                        ? AppTheme.successColor
                        : AppTheme.dangerColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 34,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 880 + (index * 70)),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return CustomPaint(
                    painter: _SparklinePainter(
                      points: data.sparkline,
                      colors: data.gradient,
                      progress: value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedMetricValue extends StatelessWidget {
  final _KpiData data;

  const _AnimatedMetricValue({required this.data});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: data.value),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final formatted = data.currency
            ? NumberFormat.currency(
          locale: 'en_IN',
          symbol: '\u20B9 ',
          decimalDigits: data.decimals,
        ).format(value)
            : NumberFormat.decimalPattern('en_IN').format(value.round());

        return Text(
          formatted,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
            height: 1.1,
          ),
        );
      },
    );
  }
}

class _ChartsSection extends StatelessWidget {
  final double width;

  const _ChartsSection({required this.width});

  @override
  Widget build(BuildContext context) {
    if (width >= 900) {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: _SalesChartCard()),
          SizedBox(width: 18),
          Expanded(flex: 5, child: _CategoryDonutCard()),
        ],
      );
    }

    return const Column(
      children: [
        _SalesChartCard(),
        SizedBox(height: 18),
        _CategoryDonutCard(),
      ],
    );
  }
}

class _SalesChartCard extends StatelessWidget {
  const _SalesChartCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassPanel(
      height: 340,
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      color: isDark
          ? const Color(0xFF1E293B).withValues(alpha: 0.62)
          : Colors.white.withValues(alpha: 0.76),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFFE2E8F0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionTitle(
                  title: 'Sales Overview',
                ),
              ),
              _ChartFilter(label: 'This Month', light: !isDark),
              const SizedBox(width: 10),
              _TinyIconButton(icon: Icons.more_horiz_rounded, dark: isDark),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _LegendDot(
                color: Color(0xFF38BDF8),
                label: 'This Month',
              ),
              SizedBox(width: 18),
              _LegendDot(
                color: Color(0xFF94A3B8),
                label: 'Last Month',
                dashed: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              _salesChartData(context),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 520.ms).slideY(begin: 0.08, end: 0);
  }
}

LineChartData _salesChartData(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final mutedColor = isDark
      ? AppTheme.darkMutedTextColor.withValues(alpha: 0.7)
      : AppTheme.lightMutedTextColor.withValues(alpha: 0.7);
  final gridColor = isDark
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFFE2E8F0);

  final thisMonth = <FlSpot>[
    const FlSpot(1, 9),
    const FlSpot(3, 14),
    const FlSpot(5, 13),
    const FlSpot(7, 22),
    const FlSpot(9, 20),
    const FlSpot(11, 25),
    const FlSpot(13, 28),
    const FlSpot(15, 29),
    const FlSpot(17, 26),
    const FlSpot(19, 33),
    const FlSpot(21, 27),
    const FlSpot(23, 34),
    const FlSpot(25, 35),
    const FlSpot(27, 40),
    const FlSpot(29, 42),
    const FlSpot(31, 47),
  ];

  final lastMonth = <FlSpot>[
    const FlSpot(1, 5),
    const FlSpot(3, 9),
    const FlSpot(5, 10),
    const FlSpot(7, 13),
    const FlSpot(9, 14),
    const FlSpot(11, 12),
    const FlSpot(13, 16),
    const FlSpot(15, 19),
    const FlSpot(17, 13),
    const FlSpot(19, 15),
    const FlSpot(21, 16),
    const FlSpot(23, 21),
    const FlSpot(25, 25),
    const FlSpot(27, 20),
    const FlSpot(29, 23),
    const FlSpot(31, 25),
  ];

  return LineChartData(
    minX: 1,
    maxX: 31,
    minY: 0,
    maxY: 52,
    gridData: FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 10,
      getDrawingHorizontalLine: (value) => FlLine(
        color: gridColor,
        strokeWidth: 1,
      ),
    ),
    borderData: FlBorderData(show: false),
    titlesData: FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 10,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => Text(
            value == 0 ? '0' : '${value.toInt()}K',
            style: TextStyle(
              color: mutedColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 5,
          reservedSize: 28,
          getTitlesWidget: (value, meta) {
            final labels = {
              1: '01 May',
              6: '05 May',
              11: '10 May',
              16: '15 May',
              21: '20 May',
              26: '24 May',
              31: '31 May',
            };
            final label = labels[value.toInt()] ?? '';
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                label,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          },
        ),
      ),
    ),
    lineTouchData: LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.95),
        tooltipRoundedRadius: 16,
        getTooltipItems: (items) {
          return items.map((item) {
            final series = item.barIndex == 0 ? 'This Month' : 'Last Month';
            return LineTooltipItem(
              '$series  \u20B9 ${(item.y * 1000).round()}',
              TextStyle(
                color: isDark ? Colors.white : AppTheme.lightTextColor,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            );
          }).toList();
        },
      ),
    ),
    lineBarsData: [
      LineChartBarData(
        spots: thisMonth,
        isCurved: true,
        curveSmoothness: 0.32,
        barWidth: 3.4,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            final shouldShow = index == 7;
            return FlDotCirclePainter(
              radius: shouldShow ? 5 : 0,
              color: const Color(0xFF60A5FA),
              strokeWidth: shouldShow ? 3 : 0,
              strokeColor: isDark ? Colors.white : Colors.white,
            );
          },
        ),
        gradient: const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF2563EB), Color(0xFF8B5CF6)],
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.34 : 0.20),
              const Color(0xFF3B82F6).withValues(alpha: 0.02),
            ],
          ),
        ),
      ),
      LineChartBarData(
        spots: lastMonth,
        isCurved: true,
        curveSmoothness: 0.32,
        barWidth: 2,
        isStrokeCapRound: true,
        color: isDark
            ? Colors.white.withValues(alpha: 0.40)
            : AppTheme.lightMutedTextColor.withValues(alpha: 0.40),
        dashArray: [5, 5],
        dotData: const FlDotData(show: false),
      ),
    ],
  );
}

class _CategoryDonutCard extends StatelessWidget {
  const _CategoryDonutCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassPanel(
      height: 340,
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(18),
      color: isDark
          ? const Color(0xFF1E293B).withValues(alpha: 0.62)
          : Colors.white.withValues(alpha: 0.76),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFFE2E8F0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionTitle(title: 'Sales by Category'),
              ),
              _ChartFilter(label: 'This Month', light: !isDark),
              const SizedBox(width: 10),
              _TinyIconButton(icon: Icons.more_horiz_rounded, dark: isDark),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 58,
                              startDegreeOffset: -90,
                              sections: [
                                for (final item in _categories)
                                  PieChartSectionData(
                                    color: item.color,
                                    value: item.percent * value,
                                    radius: 42,
                                    title: '',
                                  ),
                              ],
                            ),
                            swapAnimationDuration: const Duration(milliseconds: 700),
                            swapAnimationCurve: Curves.easeOutCubic,
                          );
                        },
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.72)
                                  : AppTheme.lightMutedTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '\u20B9 1,24,560',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppTheme.lightTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final item in _categories)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: item.color.withValues(alpha: 0.45),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : AppTheme.lightTextColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                '${item.percent.toInt()}%',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.82)
                                      : AppTheme.lightMutedTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 560.ms).slideY(begin: 0.08, end: 0);
  }
}

class _OperationsSection extends StatelessWidget {
  final double width;

  const _OperationsSection({required this.width});

  @override
  Widget build(BuildContext context) {
    if (width >= 1080) {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: _TopProductsTable()),
          SizedBox(width: 18),
          Expanded(flex: 4, child: _InventorySummary()),
          SizedBox(width: 18),
          Expanded(flex: 5, child: _GstSummary()),
        ],
      );
    }

    if (width >= 720) {
      return const Column(
        children: [
          _TopProductsTable(),
          SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _InventorySummary()),
              SizedBox(width: 18),
              Expanded(child: _GstSummary()),
            ],
          ),
        ],
      );
    }

    return const Column(
      children: [
        _TopProductsTable(),
        SizedBox(height: 18),
        _InventorySummary(),
        SizedBox(height: 18),
        _GstSummary(),
      ],
    );
  }
}

class _TopProductsTable extends StatelessWidget {
  const _TopProductsTable();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.brightness == Brightness.dark
        ? AppTheme.darkMutedTextColor
        : AppTheme.lightMutedTextColor;

    return _PanelCard(
      title: 'Top Selling Products',
      actionLabel: 'View All',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                SizedBox(width: 32, child: _TableHeaderText('#', muted: muted)),
                const Expanded(flex: 5, child: _TableHeaderText('Product')),
                const Expanded(flex: 2, child: _TableHeaderText('Sold')),
                const Expanded(flex: 3, child: _TableHeaderText('Revenue')),
              ],
            ),
          ),
          const SizedBox(height: 2),
          for (var index = 0; index < _products.length; index++)
            _ProductRow(product: _products[index], rank: index + 1),
        ],
      ),
    ).animate().fadeIn(duration: 560.ms).slideY(begin: 0.08, end: 0);
  }
}

class _TableHeaderText extends StatelessWidget {
  final String text;
  final Color? muted;

  const _TableHeaderText(this.text, {this.muted});

  @override
  Widget build(BuildContext context) {
    final color = muted ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkMutedTextColor
            : AppTheme.lightMutedTextColor);

    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final _ProductData product;
  final int rank;

  const _ProductRow({
    required this.product,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _HoverLift(
      lift: 3,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '$rank',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: product.gradient),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(product.icon, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${product.sold}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                product.revenue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventorySummary extends StatelessWidget {
  const _InventorySummary();

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'Inventory Summary',
      actionLabel: 'View All',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.22,
        children: const [
          _MiniMetricTile(
            title: 'Total Products',
            value: '1,245',
            delta: '+12.5%',
            color: Color(0xFF2563EB),
            icon: Icons.inventory_2_rounded,
          ),
          _MiniMetricTile(
            title: 'In Stock',
            value: '987',
            delta: '+8.2%',
            color: Color(0xFF10B981),
            icon: Icons.check_circle_rounded,
          ),
          _MiniMetricTile(
            title: 'Low Stock',
            value: '128',
            delta: '-2.4%',
            color: Color(0xFFF97316),
            icon: Icons.warning_amber_rounded,
            negative: true,
          ),
          _MiniMetricTile(
            title: 'Out of Stock',
            value: '18',
            delta: '-5.1%',
            color: Color(0xFFF43F5E),
            icon: Icons.remove_shopping_cart_rounded,
            negative: true,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.08, end: 0);
  }
}

class _GstSummary extends StatelessWidget {
  const _GstSummary();

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'GST Summary',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ChartFilter(label: 'This Month', light: true),
          const SizedBox(width: 8),
          _TinyIconButton(icon: Icons.more_horiz_rounded),
        ],
      ),
      child: Column(
        children: [
          const _GstTotalCard(),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _TaxCard(label: 'CGST', value: '\u20B9 9,225.00'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _TaxCard(label: 'SGST', value: '\u20B9 9,225.00'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _TaxCard(label: 'IGST', value: '\u20B9 0.00'),
        ],
      ),
    ).animate().fadeIn(duration: 640.ms).slideY(begin: 0.08, end: 0);
  }
}

class _GstTotalCard extends StatelessWidget {
  const _GstTotalCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF8FAFC).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
          isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.account_balance_rounded,
                color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total GST Collected',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppTheme.darkMutedTextColor
                        : AppTheme.lightMutedTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\u20B9 18,450.00',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxCard extends StatelessWidget {
  final String label;
  final String value;

  const _TaxCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
          isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isDark
                  ? AppTheme.darkMutedTextColor
                  : AppTheme.lightMutedTextColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RightRail extends StatelessWidget {
  const _RightRail();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuickActionsCard(),
        SizedBox(height: 18),
        _NotificationsCard(),
        SizedBox(height: 18),
        _RecentTransactionsCard(),
      ],
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'Quick Actions',
      trailing: _TinyIconButton(icon: Icons.more_horiz_rounded),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
        children: [
          for (final action in _quickActions) _QuickActionTile(action: action),
        ],
      ),
    ).animate().fadeIn(duration: 620.ms).slideX(begin: 0.05, end: 0);
  }
}

class _QuickActionTile extends StatelessWidget {
  final _QuickActionData action;

  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _HoverLift(
      lift: 3,
      scale: 1.03,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: isDark ? 0.16 : 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: action.color.withValues(alpha: 0.18)),
              ),
              child: Center(
                child: Icon(action.icon, color: action.color, size: 24),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            action.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard();

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'Alerts & Notifications',
      actionLabel: 'View All',
      child: Column(
        children: [
          for (final notification in _notifications)
            _NotificationTile(notification: notification),
        ],
      ),
    ).animate().fadeIn(duration: 680.ms).slideX(begin: 0.05, end: 0);
  }
}

class _NotificationTile extends StatelessWidget {
  final _NotificationData notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _HoverLift(
      lift: 2,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: notification.color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
              Icon(notification.icon, color: notification.color, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppTheme.darkMutedTextColor
                          : AppTheme.lightMutedTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              notification.time,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark
                    ? AppTheme.darkMutedTextColor
                    : AppTheme.lightMutedTextColor,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard();

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'Recent Transactions',
      child: Column(
        children: [
          for (final transaction in _transactions)
            _TransactionTile(transaction: transaction),
        ],
      ),
    ).animate().fadeIn(duration: 720.ms).slideX(begin: 0.05, end: 0);
  }
}

class _TransactionTile extends StatelessWidget {
  final _TransactionData transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
          isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.invoice,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.customer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppTheme.darkMutedTextColor
                        : AppTheme.lightMutedTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            transaction.time,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark
                  ? AppTheme.darkMutedTextColor
                  : AppTheme.lightMutedTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Paid',
              style: TextStyle(
                color: AppTheme.successColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomStatusBar extends StatelessWidget {
  const _BottomStatusBar();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth >= 850
              ? (constraints.maxWidth - 36) / 4
              : constraints.maxWidth >= 520
              ? (constraints.maxWidth - 12) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatusItem(
                width: itemWidth,
                icon: Icons.backup_rounded,
                title: 'Last Backup',
                value: '24 May, 03:00 AM',
                color: AppTheme.successColor,
              ),
              _StatusItem(
                width: itemWidth,
                icon: Icons.sync_rounded,
                title: 'Last Sync',
                value: '24 May, 11:45 AM',
                color: AppTheme.primaryColor,
              ),
              _StatusItem(
                width: itemWidth,
                icon: Icons.storage_rounded,
                title: 'Database Size',
                value: '512.45 MB',
                color: AppTheme.accentColor,
              ),
              _StatusItem(
                width: itemWidth,
                icon: Icons.verified_rounded,
                title: 'App Version',
                value: 'v1.0.0+125',
                color: const Color(0xFF38BDF8),
              ),
            ],
          );
        },
      ),
    ).animate().fadeIn(duration: 760.ms).slideY(begin: 0.08, end: 0);
  }
}

class _StatusItem extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatusItem({
    required this.width,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.brightness == Brightness.dark
        ? AppTheme.darkMutedTextColor
        : AppTheme.lightMutedTextColor;

    return SizedBox(
      width: width,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final String title;
  final Widget child;
  final String? actionLabel;
  final Widget? trailing;

  const _PanelCard({
    required this.title,
    required this.child,
    this.actionLabel,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      color: isDark
          ? const Color(0xFF1E293B).withValues(alpha: 0.62)
          : Colors.white.withValues(alpha: 0.76),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _SectionTitle(title: title)),
              if (trailing != null) trailing!,
              if (actionLabel != null)
                TextButton(
                  onPressed: () {},
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool dark;

  const _SectionTitle({
    required this.title,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: dark ? Colors.white : null,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class _ChartFilter extends StatelessWidget {
  final String label;
  final bool light;

  const _ChartFilter({
    required this.label,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = light ? null : Colors.white;
    final borderColor = light
        ? (Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE2E8F0))
        : Colors.white.withValues(alpha: 0.14);

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: light ? null : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 16),
        ],
      ),
    );
  }
}

class _TinyIconButton extends StatelessWidget {
  final IconData icon;
  final bool dark;

  const _TinyIconButton({
    required this.icon,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.14)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Icon(icon, color: dark ? Colors.white : null, size: 18),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  final bool dark;

  const _LegendDot({
    required this.color,
    required this.label,
    this.dashed = false,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dashed ? 18 : 10,
          height: dashed ? 2 : 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: dark ? Colors.white.withValues(alpha: 0.78) : null,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MiniMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String delta;
  final Color color;
  final IconData icon;
  final bool negative;

  const _MiniMetricTile({
    required this.title,
    required this.value,
    required this.delta,
    required this.color,
    required this.icon,
    this.negative = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.13 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          Row(
            children: [
              Icon(
                negative
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: negative ? AppTheme.dangerColor : AppTheme.successColor,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                delta,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: negative
                      ? AppTheme.dangerColor
                      : AppTheme.successColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HoverLift extends StatefulWidget {
  final Widget child;
  final double lift;
  final double scale;

  const _HoverLift({
    required this.child,
    this.lift = 5,
    this.scale = 1.01,
  });

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? widget.scale : 1,
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOutCubic,
        child: AnimatedSlide(
          offset: _hovering ? Offset(0, -widget.lift / 100) : Offset.zero,
          duration: const Duration(milliseconds: 190),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final List<Color> colors;
  final double progress;

  _SparklinePainter({
    required this.points,
    required this.colors,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || progress <= 0) return;

    final minValue = points.reduce(math.min);
    final maxValue = points.reduce(math.max);
    final range = math.max(1, maxValue - minValue);
    final visibleCount =
    math.max(2, (points.length * progress).ceil().clamp(2, points.length));

    final path = Path();
    for (var index = 0; index < visibleCount; index++) {
      final x = (index / (points.length - 1)) * size.width;
      final normalized = (points[index] - minValue) / range;
      final y = size.height - (normalized * (size.height - 6)) - 3;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(colors: colors).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final fillPath = Path.from(path)
      ..lineTo(
          ((visibleCount - 1) / (points.length - 1)) * size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.last.withValues(alpha: 0.18),
          colors.last.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.points != points ||
        oldDelegate.colors != colors;
  }
}

class _KpiData {
  final String title;
  final double value;
  final bool currency;
  final int decimals;
  final IconData icon;
  final double growth;
  final List<Color> gradient;
  final List<double> sparkline;

  const _KpiData({
    required this.title,
    required this.value,
    required this.currency,
    required this.decimals,
    required this.icon,
    required this.growth,
    required this.gradient,
    required this.sparkline,
  });
}

const _kpis = [
  _KpiData(
    title: 'Total Sales',
    value: 124560,
    currency: true,
    decimals: 2,
    icon: Icons.receipt_long_rounded,
    growth: 12.5,
    gradient: [Color(0xFF38BDF8), Color(0xFF2563EB), Color(0xFF7C3AED)],
    sparkline: [30, 28, 25, 27, 31, 26, 39, 34, 42, 38, 45, 52],
  ),
  _KpiData(
    title: 'Total Profit',
    value: 32450,
    currency: true,
    decimals: 2,
    icon: Icons.trending_up_rounded,
    growth: 8.3,
    gradient: [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF06B6D4)],
    sparkline: [18, 20, 17, 22, 35, 28, 31, 39, 34, 42, 29, 48],
  ),
  _KpiData(
    title: 'Invoices',
    value: 126,
    currency: false,
    decimals: 0,
    icon: Icons.assignment_rounded,
    growth: 11.2,
    gradient: [Color(0xFFC084FC), Color(0xFF8B5CF6), Color(0xFF6366F1)],
    sparkline: [22, 17, 14, 20, 28, 31, 34, 42, 35, 39, 51, 49],
  ),
  _KpiData(
    title: 'Average Order',
    value: 2450,
    currency: true,
    decimals: 2,
    icon: Icons.local_mall_rounded,
    growth: 5.4,
    gradient: [Color(0xFFFBBF24), Color(0xFFF97316), Color(0xFFEC4899)],
    sparkline: [15, 19, 21, 27, 24, 22, 32, 30, 25, 34, 49, 46],
  ),
  _KpiData(
    title: 'Customers',
    value: 1245,
    currency: false,
    decimals: 0,
    icon: Icons.group_rounded,
    growth: 3.6,
    gradient: [Color(0xFFF9A8D4), Color(0xFFEC4899), Color(0xFFF43F5E)],
    sparkline: [26, 18, 21, 28, 31, 27, 35, 31, 29, 36, 42, 55],
  ),
];

class _CategoryData {
  final String label;
  final double percent;
  final Color color;

  const _CategoryData(this.label, this.percent, this.color);
}

const _categories = [
  _CategoryData('Electronics', 38, Color(0xFF3B82F6)),
  _CategoryData('Mobiles', 24, Color(0xFF8B5CF6)),
  _CategoryData('Accessories', 18, Color(0xFF22C55E)),
  _CategoryData('Fashion', 12, Color(0xFFF59E0B)),
  _CategoryData('Others', 8, Color(0xFF94A3B8)),
];

class _ProductData {
  final String name;
  final int sold;
  final String revenue;
  final IconData icon;
  final List<Color> gradient;

  const _ProductData({
    required this.name,
    required this.sold,
    required this.revenue,
    required this.icon,
    required this.gradient,
  });
}

const _products = [
  _ProductData(
    name: 'iPhone 15 Pro Max',
    sold: 32,
    revenue: '\u20B9 2,56,000',
    icon: Icons.phone_iphone_rounded,
    gradient: [Color(0xFF0F172A), Color(0xFF64748B)],
  ),
  _ProductData(
    name: 'Samsung Galaxy S24',
    sold: 28,
    revenue: '\u20B9 1,67,440',
    icon: Icons.smartphone_rounded,
    gradient: [Color(0xFF312E81), Color(0xFF60A5FA)],
  ),
  _ProductData(
    name: 'Noise Air Buds',
    sold: 45,
    revenue: '\u20B9 67,500',
    icon: Icons.earbuds_rounded,
    gradient: [Color(0xFF111827), Color(0xFF334155)],
  ),
  _ProductData(
    name: 'Boat Rockerz 450',
    sold: 38,
    revenue: '\u20B9 45,600',
    icon: Icons.headphones_rounded,
    gradient: [Color(0xFF1E293B), Color(0xFF7C3AED)],
  ),
  _ProductData(
    name: 'HP Laptop 15s',
    sold: 12,
    revenue: '\u20B9 3,60,000',
    icon: Icons.laptop_mac_rounded,
    gradient: [Color(0xFF2563EB), Color(0xFF06B6D4)],
  ),
];

class _QuickActionData {
  final String label;
  final IconData icon;
  final Color color;

  const _QuickActionData(this.label, this.icon, this.color);
}

const _quickActions = [
  _QuickActionData(
      'New Invoice', Icons.receipt_long_rounded, Color(0xFF2563EB)),
  _QuickActionData(
      'Add Product', Icons.add_shopping_cart_rounded, Color(0xFF10B981)),
  _QuickActionData('Stock In', Icons.inventory_rounded, Color(0xFFEC4899)),
  _QuickActionData('Purchase', Icons.shopping_bag_rounded, Color(0xFFF97316)),
  _QuickActionData('Customer', Icons.person_add_alt_rounded, Color(0xFFF43F5E)),
  _QuickActionData('Supplier', Icons.group_add_rounded, Color(0xFF8B5CF6)),
  _QuickActionData(
      'Expense', Icons.account_balance_wallet_rounded, Color(0xFF2563EB)),
  _QuickActionData('More', Icons.more_horiz_rounded, Color(0xFF64748B)),
];

class _NotificationData {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  const _NotificationData({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });
}

const _notifications = [
  _NotificationData(
    title: 'Low Stock Alert',
    subtitle: '12 products are running low',
    time: '10m ago',
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFF97316),
  ),
  _NotificationData(
    title: 'Invoice Due',
    subtitle: '8 invoices are overdue',
    time: '1h ago',
    icon: Icons.receipt_long_rounded,
    color: Color(0xFFF43F5E),
  ),
  _NotificationData(
    title: 'Expiry Alert',
    subtitle: '5 products are expiring soon',
    time: '2h ago',
    icon: Icons.event_busy_rounded,
    color: Color(0xFFF59E0B),
  ),
  _NotificationData(
    title: 'Sync Completed',
    subtitle: 'All data synced successfully',
    time: '3h ago',
    icon: Icons.sync_rounded,
    color: Color(0xFF10B981),
  ),
];

class _TransactionData {
  final String invoice;
  final String customer;
  final String time;

  const _TransactionData(this.invoice, this.customer, this.time);
}

const _transactions = [
  _TransactionData('INV-10025', 'Rajesh Kumar', '24 May, 11:30 AM'),
  _TransactionData('INV-10024', 'Priya Sharma', '24 May, 11:20 AM'),
  _TransactionData('INV-10023', 'Amit Verma', '24 May, 11:10 AM'),
  _TransactionData('INV-10022', 'Neha Gupta', '24 May, 11:00 AM'),
];
