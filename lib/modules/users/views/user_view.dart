import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../database/database.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/user_controller.dart';

class UserView extends GetView<UserController> {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Users',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1280;

          return Obx(() {
            if (controller.isLoading.value && controller.users.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _UserKpiGrid(width: width),
                  const SizedBox(height: 18),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _MainUserContent()),
                        const SizedBox(width: 18),
                        const Expanded(flex: 3, child: _UserRightRail()),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _MainUserContent(),
                        const SizedBox(height: 18),
                        const _UserRightRail(),
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

class _UserKpiGrid extends GetView<UserController> {
  final double width;

  const _UserKpiGrid({required this.width});

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
      _UserKpiData(
        title: 'Total Users',
        value: controller.totalUsers.toDouble(),
        growth: 12.5,
        icon: Icons.people_outline,
        gradient: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
        sparkline: [25, 30, 28, 35, 32, 40, 38],
      ),
      _UserKpiData(
        title: 'Active Users',
        value: controller.activeUsers.toDouble(),
        growth: 15.0,
        icon: Icons.person_add_alt_1_outlined,
        gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        sparkline: [20, 22, 25, 23, 28, 30, 35],
      ),
      _UserKpiData(
        title: 'New Users',
        value: controller.newUsers.toDouble(),
        growth: 25.0,
        icon: Icons.person_search_outlined,
        gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        sparkline: [10, 12, 15, 13, 18, 20, 25],
      ),
      _UserKpiData(
        title: 'Inactive Users',
        value: controller.inactiveUsers.toDouble(),
        growth: -25.0,
        icon: Icons.person_off_outlined,
        gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        sparkline: [40, 38, 35, 30, 25, 20, 15],
      ),
      _UserKpiData(
        title: 'Avg. Login (Today)',
        value: controller.avgLoginToday,
        growth: 7.7,
        icon: Icons.login_outlined,
        gradient: [const Color(0xFFEC4899), const Color(0xFFDB2777)],
        sparkline: [30, 32, 35, 34, 38, 40, 42],
        isDecimal: true,
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
        return _UserKpiCard(data: kpis[index])
            .animate()
            .fadeIn(delay: (70 * index).ms, duration: 420.ms)
            .slideY(begin: 0.14, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _UserKpiData {
  final String title;
  final double value;
  final double growth;
  final IconData icon;
  final List<Color> gradient;
  final List<double> sparkline;
  final bool isDecimal;

  const _UserKpiData({
    required this.title,
    required this.value,
    required this.growth,
    required this.icon,
    required this.gradient,
    required this.sparkline,
    this.isDecimal = false,
  });
}

class _UserKpiCard extends StatelessWidget {
  final _UserKpiData data;

  const _UserKpiCard({required this.data});

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
                      data.isDecimal ? data.value.toStringAsFixed(1) : data.value.toInt().toString(),
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

class _MainUserContent extends GetView<UserController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassPanel(
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _UserTabs(),
              const SizedBox(height: 18),
              _UserFilterBar(),
              const SizedBox(height: 18),
              _UserTable(),
              const SizedBox(height: 20),
              _TablePagination(),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _LoginActivityChart(),
      ],
    );
  }
}

class _UserTabs extends GetView<UserController> {
  @override
  Widget build(BuildContext context) {
    final tabs = ['All Users', 'Roles & Permissions', 'Activity Logs'];

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

class _UserFilterBar extends GetView<UserController> {
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
                      hintText: 'Search by name, email, phone or username...',
                      hintStyle: TextStyle(color: muted, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _FilterDropdown(label: 'All Roles'),
        const SizedBox(width: 12),
        _FilterDropdown(label: 'All Status'),
        const SizedBox(width: 12),
        _ActionButton(icon: Icons.tune_rounded, label: 'Filters'),
        const SizedBox(width: 12),
        _AddUserButton(),
      ],
    );
  }
}

class _AddUserButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: () {},
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
            Text('Add User', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          ],
        ),
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
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted)),
          const SizedBox(width: 4),
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

class _UserTable extends GetView<UserController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    final columns = ['User', 'Role', 'Email / Phone', 'Status', 'Last Login', 'Action'];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9))),
          ),
          child: Row(
            children: [
              SizedBox(width: 30, child: Checkbox(value: false, onChanged: (v) {}, visualDensity: VisualDensity.compact)),
              for (var i = 0; i < columns.length; i++)
                Expanded(
                  flex: i == 0 || i == 2 ? 3 : 2,
                  child: Text(
                    columns[i],
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: muted),
                  ),
                ),
            ],
          ),
        ),
        Obx(() {
          final list = controller.filteredUsers;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _UserRow(user: list[index]);
            },
          );
        }),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  final User user;

  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;
    
    final status = 'Active';
    final statusColor = Colors.green;
    final lastLogin = 'May 24, 2025 11:30 AM';
    final roleColor = user.role == 'Admin' ? Colors.purple : (user.role == 'Manager' ? Colors.blue : Colors.teal);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          SizedBox(width: 30, child: Checkbox(value: false, onChanged: (v) {}, visualDensity: VisualDensity.compact)),
          // User Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  backgroundImage: const NetworkImage('https://i.pravatar.cc/150'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(width: 4),
                          if (user.username == 'admin')
                            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('You', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue))),
                        ],
                      ),
                      Text(user.username, style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Role
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(user.role, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: roleColor)),
              ),
            ),
          ),
          // Email / Phone
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${user.username}@printonex.com', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('+91 98765 43210', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Status
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor)),
              ),
            ),
          ),
          // Last Login
          Expanded(
            flex: 2,
            child: Text(lastLogin, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          // Action
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _TableActionIcon(icon: Icons.visibility_outlined, onTap: () {}),
                _TableActionIcon(icon: Icons.edit_outlined, onTap: () {}),
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
        const Text('Showing 1 to 8 of 28 users', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        const Spacer(),
        _PaginationButton(icon: Icons.chevron_left_rounded),
        const SizedBox(width: 8),
        _PageNumber(number: 1, active: true),
        _PageNumber(number: 2),
        _PageNumber(number: 3),
        _PageNumber(number: 4),
        const Text('...', style: TextStyle(color: Colors.grey)),
        _PageNumber(number: 7),
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

class _LoginActivityChart extends StatelessWidget {
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
              const Expanded(child: Text('Login Activity', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              _SmallDropdown(label: 'This Month'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _LegendDot(color: Colors.blue, label: 'Logins'),
              const SizedBox(width: 16),
              _LegendDot(color: Colors.green, label: 'Unique Users'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 1, maxX: 31, minY: 0, maxY: 40,
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, m) {
                        if (v % 5 == 0 || v == 1) return Text('${v.toInt()} May', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey));
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(1, 15), FlSpot(5, 25), FlSpot(10, 20), FlSpot(15, 30), FlSpot(20, 28), FlSpot(25, 35), FlSpot(31, 32)],
                    isCurved: true, color: Colors.blue, barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(1, 10), FlSpot(5, 18), FlSpot(10, 15), FlSpot(15, 22), FlSpot(20, 20), FlSpot(25, 25), FlSpot(31, 23)],
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

class _UserRightRail extends StatelessWidget {
  const _UserRightRail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _UserRolesChart(),
        SizedBox(height: 18),
        _RecentUserActivity(),
        SizedBox(height: 18),
        _UserStatusOverview(),
      ],
    );
  }
}

class _UserRolesChart extends GetView<UserController> {
  const _UserRolesChart();

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.blue, Colors.indigo, Colors.orange, Colors.amber, Colors.grey];
    final data = controller.roleDistribution;
    final total = data.values.fold(0.0, (s, e) => s + e);

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('User Roles Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
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
                    sectionsSpace: 2, centerSpaceRadius: 50,
                    sections: data.entries.indexed.map((e) {
                      return PieChartSectionData(color: colors[e.$1 % colors.length], value: e.$2.value, title: '', radius: 25);
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${total.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                    const Text('Total', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...data.entries.indexed.map((e) {
            final percentage = (e.$2.value / total * 100).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[e.$1 % colors.length], shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(e.$2.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                  Text('${e.$2.value.toInt()} ($percentage%)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RecentUserActivity extends StatelessWidget {
  const _RecentUserActivity();

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
              const Expanded(child: Text('Recent User Activity', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 12),
          _ActivityItem(name: 'Rahul Sharma', action: 'Logged in', time: '11:30 AM'),
          _ActivityItem(name: 'Priya Singh', action: 'Created New Invoice', time: '10:45 AM'),
          _ActivityItem(name: 'Amit Mehta', action: 'Updated Product', time: '10:20 AM'),
          _ActivityItem(name: 'Neha Kapoor', action: 'Admin User', time: '09:50 AM'),
          _ActivityItem(name: 'Sanjay Kumar', action: 'Changed User Role', time: '09:10 AM'),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String name, action, time;
  const _ActivityItem({required this.name, required this.action, required this.time});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: Colors.blue.withOpacity(0.1), child: Text(name.substring(0, 1), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), Text(action, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600))])),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _UserStatusOverview extends StatelessWidget {
  const _UserStatusOverview();

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
              const Expanded(child: Text('User Status Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 12),
          _ProgressBarItem(label: 'Active Users', value: 23, total: 28, color: Colors.green),
          _ProgressBarItem(label: 'Inactive Users', value: 3, total: 28, color: Colors.red),
          _ProgressBarItem(label: 'Locked Users', value: 2, total: 28, color: Colors.orange),
          _ProgressBarItem(label: 'New This Month', value: 5, total: 28, color: Colors.blue),
        ],
      ),
    );
  }
}

class _ProgressBarItem extends StatelessWidget {
  final String label;
  final int value, total;
  final Color color;

  const _ProgressBarItem({required this.label, required this.value, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final progress = value / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(label.contains('Active') ? Icons.check_circle_outline : (label.contains('Inactive') ? Icons.cancel_outlined : Icons.lock_outline), size: 14, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
              Text('$value', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_upward_rounded, size: 10, color: color),
              Text(' 15.0%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
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
