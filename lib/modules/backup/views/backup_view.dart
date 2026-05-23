import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/backup_controller.dart';

class BackupView extends GetView<BackupController> {
  const BackupView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Backup & Restore',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1280;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BackupKpiGrid(width: width),
                const SizedBox(height: 18),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _MainBackupContent()),
                      const SizedBox(width: 18),
                      const Expanded(flex: 3, child: _BackupRightRail()),
                    ],
                  )
                else
                  Column(
                    children: [
                      _MainBackupContent(),
                      const SizedBox(height: 18),
                      const _BackupRightRail(),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BackupKpiGrid extends StatelessWidget {
  final double width;
  const _BackupKpiGrid({required this.width});

  @override
  Widget build(BuildContext context) {
    final columns = width >= 1100 ? 4 : (width >= 600 ? 2 : 1);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      mainAxisExtent: 110,
      children: const [
        _BackupKpiCard(title: 'Last Backup', value: 'Today, 02:30 AM', status: 'Success', icon: Icons.cloud_done_outlined, color: Colors.blue),
        _BackupKpiCard(title: 'Total Backups', value: '48', status: 'All time backups', icon: Icons.storage_outlined, color: Colors.indigo),
        _BackupKpiCard(title: 'Backup Size', value: '12.45 GB', status: '62% of 20 GB', icon: Icons.analytics_outlined, color: Colors.teal, progress: 0.62),
        _BackupKpiCard(title: 'Next Scheduled', value: 'Tomorrow, 02:30 AM', status: 'Scheduled', icon: Icons.schedule_outlined, color: Colors.orange),
      ],
    );
  }
}

class _BackupKpiCard extends StatelessWidget {
  final String title, value, status;
  final IconData icon;
  final Color color;
  final double? progress;

  const _BackupKpiCard({required this.title, required this.value, required this.status, required this.icon, required this.color, this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.brightness == Brightness.dark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: muted)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                if (progress != null) ...[
                  const SizedBox(height: 4),
                  ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(color))),
                  const SizedBox(height: 2),
                  Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: muted)),
                ] else
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainBackupContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 5, child: _BackupTypesGrid()),
            const SizedBox(width: 18),
            Expanded(flex: 5, child: _AutoBackupSettings()),
          ],
        ),
        const SizedBox(height: 18),
        const _BackupHistoryTable(),
        const SizedBox(height: 18),
        const _RestoreBackupPanel(),
      ],
    );
  }
}

class _BackupTypesGrid extends StatelessWidget {
  const _BackupTypesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Choose backup type and start securing your data', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: _BackupTypeCard(title: 'Full Backup', icon: Icons.folder_copy_outlined, color: Colors.blue)),
              SizedBox(width: 12),
              Expanded(child: _BackupTypeCard(title: 'Incremental', icon: Icons.history_outlined, color: Colors.indigo)),
              SizedBox(width: 12),
              Expanded(child: _BackupTypeCard(title: 'Database', icon: Icons.storage_rounded, color: Colors.teal)),
              SizedBox(width: 12),
              Expanded(child: _BackupTypeCard(title: 'Cloud Backup', icon: Icons.cloud_upload_outlined, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _BigBtn(label: 'Create Full Backup', color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _BigBtn(label: 'Create Incremental', color: Colors.indigo)),
              const SizedBox(width: 12),
              Expanded(child: _BigBtn(label: 'Backup Database', color: Colors.teal)),
              const SizedBox(width: 12),
              Expanded(child: _BigBtn(label: 'Upload to Cloud', color: Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackupTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _BackupTypeCard({required this.title, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.1))),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 4),
          const Text('Backup all data including settings...', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Colors.grey, height: 1.3)),
        ],
      ),
    );
  }
}

class _BigBtn extends StatelessWidget {
  final String label;
  final Color color;
  const _BigBtn({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 36, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))));
  }
}

class _AutoBackupSettings extends StatelessWidget {
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
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Auto Backup', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), Text('Enable automatic scheduled backups', style: TextStyle(fontSize: 11, color: Colors.grey))])),
              Switch(value: true, onChanged: (v) {}, activeColor: const Color(0xFF4F46E5)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Backup Time', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)), SizedBox(height: 8), _SmallDropdown(label: '02:30 AM')])),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Backup Frequency', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)), SizedBox(height: 8), _SmallDropdown(label: 'Daily')])),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Keep Backups', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)), SizedBox(height: 8), _SmallDropdown(label: '30 Days')])),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Text('Include Images & Docs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              Switch(value: true, onChanged: (v) {}, activeColor: const Color(0xFF4F46E5)),
            ],
          ),
          Row(
            children: [
              const Expanded(child: Text('Include Reports', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              Switch(value: true, onChanged: (v) {}, activeColor: const Color(0xFF4F46E5)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(height: 44, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.w800)))),
        ],
      ),
    );
  }
}

class _BackupHistoryTable extends StatelessWidget {
  const _BackupHistoryTable();
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: const [
          _BackupFilterBar(),
          SizedBox(height: 18),
          _Table(),
          SizedBox(height: 20),
          _Pagination(),
        ],
      ),
    );
  }
}

class _BackupFilterBar extends StatelessWidget {
  const _BackupFilterBar();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Backup History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(width: 24),
        Expanded(child: Container(height: 36, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)), child: Row(children: const [Icon(Icons.search_rounded, color: Colors.grey, size: 16), SizedBox(width: 8), Expanded(child: TextField(decoration: InputDecoration(hintText: 'Search backups...', hintStyle: TextStyle(color: Colors.grey, fontSize: 12), border: InputBorder.none, isDense: true)))]))),
        const SizedBox(width: 12),
        const _SmallFilterDropdown(label: 'All Types'),
        const SizedBox(width: 12),
        const _SmallFilterDropdown(label: 'All Status'),
        const SizedBox(width: 12),
        const _IconActionButton(icon: Icons.tune_rounded),
        const SizedBox(width: 12),
        const _IconActionButton(icon: Icons.refresh_rounded),
      ],
    );
  }
}

class _Table extends StatelessWidget {
  const _Table();
  @override
  Widget build(BuildContext context) {
    final columns = ['#', 'Backup Name', 'Type', 'Size', 'Date & Time', 'Location', 'Status', 'Action'];
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1)))),
          child: Row(children: columns.map((col) => Expanded(flex: col == 'Backup Name' ? 3 : 2, child: Text(col, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)))).toList()),
        ),
        const _BackupRow(index: 1, name: 'Full Backup - May 24, 2025', type: 'Full Backup', size: '2.45 GB', time: 'May 24, 2025 02:30 AM', location: 'Local + Cloud', status: 'Success'),
        const _BackupRow(index: 2, name: 'Incremental - May 23, 2025', type: 'Incremental', size: '325 MB', time: 'May 23, 2025 02:30 AM', location: 'Local + Cloud', status: 'Success'),
        const _BackupRow(index: 3, name: 'Full Backup - May 22, 2025', type: 'Full Backup', size: '2.38 GB', time: 'May 22, 2025 02:30 AM', location: 'Local + Cloud', status: 'Success'),
        const _BackupRow(index: 4, name: 'Database Backup - May 21, 2025', type: 'Database', size: '1.15 GB', time: 'May 21, 2025 02:30 AM', location: 'Local', status: 'Success'),
        const _BackupRow(index: 5, name: 'Incremental - May 20, 2025', type: 'Incremental', size: '298 MB', time: 'May 20, 2025 02:30 AM', location: 'Local + Cloud', status: 'Failed'),
      ],
    );
  }
}

class _BackupRow extends StatelessWidget {
  final int index;
  final String name, type, size, time, location, status;
  const _BackupRow({required this.index, required this.name, required this.type, required this.size, required this.time, required this.location, required this.status});
  @override
  Widget build(BuildContext context) {
    final statusColor = status == 'Success' ? Colors.green : (status == 'Failed' ? Colors.red : Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.05)))),
      child: Row(children: [Expanded(flex: 2, child: Text('$index', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey))), Expanded(flex: 3, child: Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))), Expanded(flex: 2, child: Text(type, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))), Expanded(flex: 2, child: Text(size, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))), Expanded(flex: 2, child: Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))), Expanded(flex: 2, child: Text(location, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))), Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: statusColor))))), Expanded(flex: 2, child: Row(children: const [Icon(Icons.download_rounded, size: 16, color: Colors.blue), SizedBox(width: 8), Icon(Icons.cloud_outlined, size: 16, color: Colors.grey), SizedBox(width: 8), Icon(Icons.more_vert_rounded, size: 16, color: Colors.grey)]))],),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination();
  @override
  Widget build(BuildContext context) {
    return Row(children: [const Text('Showing 1 to 10 of 48 backups', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)), const Spacer(), const _PageNumber(number: 1, active: true), const _PageNumber(number: 2), const _PageNumber(number: 3), const _PageNumber(number: 4), const _PageNumber(number: 5), const Text('...', style: TextStyle(color: Colors.grey, fontSize: 10)), const _PageNumber(number: 5), const Spacer(), const Text('Rows per page:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(6)), child: Row(children: const [Text('10', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)), SizedBox(width: 4), Icon(Icons.keyboard_arrow_down_rounded, size: 14)]))]);
  }
}

class _RestoreBackupPanel extends StatelessWidget {
  const _RestoreBackupPanel();
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Restore Backup', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const Text('Select a backup from history to restore your data', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.withOpacity(0.1))), child: Row(children: [const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Warning: Restoring will replace current data with the backup data. Please ensure you have a recent backup.', style: TextStyle(fontSize: 11, color: Colors.orange, height: 1.4, fontWeight: FontWeight.w700))]))])),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Select Backup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey)), SizedBox(height: 8), _SmallDropdown(label: 'Choose a backup to restore')])),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: const [
                        Text('Restore Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey)),
                        Spacer(),
                        _RadioOption(label: 'Complete Restore', selected: true),
                        SizedBox(width: 24),
                        _RadioOption(label: 'Selective Restore', selected: false),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.history_rounded), label: const Text('Start Restore', style: TextStyle(fontWeight: FontWeight.w800)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
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

class _BackupRightRail extends StatelessWidget {
  const _BackupRightRail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _StorageOverviewChart(),
        SizedBox(height: 18),
        _RecentActivityPanel(),
        SizedBox(height: 18),
        _QuickInfoCard(),
        SizedBox(height: 18),
        _BackupTipsCard(),
      ],
    );
  }
}

class _StorageOverviewChart extends StatelessWidget {
  const _StorageOverviewChart();

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
              const Expanded(child: Text('Storage Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              const Icon(Icons.more_horiz, color: Colors.grey),
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
                    sections: [
                      PieChartSectionData(color: Colors.blue, value: 42, title: '', radius: 25),
                      PieChartSectionData(color: Colors.green, value: 28, title: '', radius: 25),
                      PieChartSectionData(color: Colors.orange, value: 17, title: '', radius: 25),
                      PieChartSectionData(color: Colors.purple, value: 13, title: '', radius: 25),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Total', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)),
                    Text('12.45 GB', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _StorageLegend(label: 'Database', size: '5.25 GB (42%)', color: Colors.blue),
          const _StorageLegend(label: 'Images & Docs', size: '3.45 GB (28%)', color: Colors.green),
          const _StorageLegend(label: 'Reports', size: '2.15 GB (17%)', color: Colors.orange),
          const _StorageLegend(label: 'Others', size: '1.60 GB (13%)', color: Colors.purple),
        ],
      ),
    );
  }
}

class _StorageLegend extends StatelessWidget {
  final String label, size;
  final Color color;
  const _StorageLegend({required this.label, required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
          Text(size, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _RecentActivityPanel extends StatelessWidget {
  const _RecentActivityPanel();

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
              const Expanded(child: Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 12),
          const _ActivityItem(title: 'Backup Created', sub: 'Full Backup • 02:30 AM', status: 'Success'),
          const _ActivityItem(title: 'Backup Uploaded', sub: 'Full Backup • May 23, 11:45 PM', status: 'Success'),
          const _ActivityItem(title: 'Backup Restored', sub: 'Database • May 22, 10:15 AM', status: 'Success'),
          const _ActivityItem(title: 'Backup Failed', sub: 'Full Backup • May 21, 02:30 AM', status: 'Failed'),
          const _ActivityItem(title: 'Backup Deleted', sub: 'Incremental • May 20, 09:30 PM', status: 'Deleted'),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title, sub, status;
  const _ActivityItem({required this.title, required this.sub, required this.status});
  @override
  Widget build(BuildContext context) {
    final color = status == 'Success' ? Colors.green : (status == 'Failed' ? Colors.red : Colors.grey);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(status == 'Success' ? Icons.cloud_done_outlined : (status == 'Failed' ? Icons.error_outline : Icons.delete_outline), size: 16, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(status, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: color))),
        ],
      ),
    );
  }
}

class _QuickInfoCard extends StatelessWidget {
  const _QuickInfoCard();
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(children: const [Expanded(child: Text('Quick Info', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)))]),
          const SizedBox(height: 18),
          const _QuickRow(label: 'Last Backup Size', value: '2.45 GB'),
          const _QuickRow(label: 'Total Records', value: '1,24,580'),
          const _QuickRow(label: 'Database Size', value: '5.25 GB'),
          const _QuickRow(label: 'Backup Location', value: 'Local + Cloud'),
          const _QuickRow(label: 'Cloud Provider', value: 'Google Drive'),
          const _QuickRow(label: 'Backup Path', value: '/storage/backups/'),
        ],
      ),
    );
  }
}

class _QuickRow extends StatelessWidget {
  final String label, value;
  const _QuickRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)), Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))]));
  }
}

class _BackupTipsCard extends StatelessWidget {
  const _BackupTipsCard();
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Backup Tips', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          SizedBox(height: 18),
          _TipItem(text: 'Keep regular backups to avoid data loss.'),
          _TipItem(text: 'Store important backups in cloud.'),
          _TipItem(text: 'Test restore process periodically.'),
          _TipItem(text: 'Keep at least 2-3 recent backups.'),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [const Icon(Icons.check_rounded, size: 14, color: Colors.blue), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)))]));
  }
}

class _SmallDropdown extends StatelessWidget {
  final String label;
  const _SmallDropdown({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.withOpacity(0.2))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey)]));
  }
}

class _SmallFilterDropdown extends StatelessWidget {
  final String label;
  const _SmallFilterDropdown({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(height: 36, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)), child: Row(children: [Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)), const SizedBox(width: 6), const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Colors.grey)]));
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  const _IconActionButton({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(width: 36, height: 36, decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: Colors.grey));
  }
}

class _PageNumber extends StatelessWidget {
  final int number;
  final bool active;
  const _PageNumber({required this.number, this.active = false});
  @override
  Widget build(BuildContext context) {
    return Container(width: 28, height: 28, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: active ? const Color(0xFF4F46E5) : Colors.transparent, borderRadius: BorderRadius.circular(6)), child: Center(child: Text('$number', style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.w800, fontSize: 10))));
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  const _RadioOption({required this.label, required this.selected});
  @override
  Widget build(BuildContext context) {
    return Row(children: [Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? const Color(0xFF4F46E5) : Colors.grey, width: selected ? 4 : 1))), const SizedBox(width: 8), Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w800 : FontWeight.w600))]);
  }
}
