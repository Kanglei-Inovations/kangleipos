import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/sync_controller.dart';

class SyncView extends GetView<SyncController> {
  const SyncView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Sync Center',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1280;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SyncKpiGrid(width: width),
                const SizedBox(height: 18),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _MainSyncContent()),
                      const SizedBox(width: 18),
                      const Expanded(flex: 3, child: _SyncRightRail()),
                    ],
                  )
                else
                  Column(
                    children: [
                      _MainSyncContent(),
                      const SizedBox(height: 18),
                      const _SyncRightRail(),
                    ],
                  ),
                const SizedBox(height: 18),
                const _SyncInfoBanner(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SyncKpiGrid extends StatelessWidget {
  final double width;
  const _SyncKpiGrid({required this.width});

  @override
  Widget build(BuildContext context) {
    final columns = width >= 1100 ? 5 : (width >= 700 ? 3 : 2);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      mainAxisExtent: 110,
      children: const [
        _SyncKpiCard(title: 'Overall Sync Status', value: 'Synced', sub: 'All data is up to date', icon: Icons.check_circle_outline, color: Colors.green),
        _SyncKpiCard(title: 'Last Successful Sync', value: '10:30 AM', sub: '2 minutes ago', icon: Icons.schedule_outlined, color: Colors.blue),
        _SyncKpiCard(title: 'Pending Changes', value: '0', sub: 'No pending changes', icon: Icons.sync_problem_outlined, color: Colors.orange),
        _SyncKpiCard(title: 'Devices Connected', value: '3', sub: 'Active devices', icon: Icons.devices_outlined, color: Colors.indigo),
        _SyncKpiCard(title: 'Auto Sync', value: 'Enabled', sub: 'Every 15 minutes', icon: Icons.autorenew_outlined, color: Colors.teal),
      ],
    );
  }
}

class _SyncKpiCard extends StatelessWidget {
  final String title, value, sub;
  final IconData icon;
  final Color color;

  const _SyncKpiCard({required this.title, required this.value, required this.sub, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color == Colors.green ? Colors.green : null)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainSyncContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SyncTabs(),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 3, child: _DataModulesStatus()),
            const SizedBox(width: 18),
            Expanded(flex: 7, child: _RecentSyncActivity()),
          ],
        ),
        const SizedBox(height: 18),
        const _SyncConflictsPanel(),
      ],
    );
  }
}

class _SyncTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabs = ['Sync Overview', 'Data Status', 'Devices', 'Sync History', 'Conflict Resolution', 'Settings'];
    return Row(
      children: tabs.map((tab) {
        final isSelected = tab == 'Sync Overview';
        return Container(
          margin: const EdgeInsets.only(right: 24),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent, width: 2))),
          child: Text(tab, style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? const Color(0xFF4F46E5) : Colors.grey, fontSize: 13)),
        );
      }).toList(),
    );
  }
}

class _DataModulesStatus extends StatelessWidget {
  const _DataModulesStatus();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data Modules Status', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 20),
          const _ModuleItem(label: 'Sales', status: 'Synced'),
          const _ModuleItem(label: 'Purchases', status: 'Synced'),
          const _ModuleItem(label: 'Inventory', status: 'Synced'),
          const _ModuleItem(label: 'Customers', status: 'Synced'),
          const _ModuleItem(label: 'Suppliers', status: 'Synced'),
          const _ModuleItem(label: 'Products', status: 'Synced'),
          const _ModuleItem(label: 'Expenses', status: 'Synced'),
          const _ModuleItem(label: 'GST / Tax', status: 'Synced'),
          const _ModuleItem(label: 'Users & Roles', status: 'Synced'),
          const _ModuleItem(label: 'Settings', status: 'Synced'),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF4F46E5), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFF4F46E5)))), child: const Text('View Data Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)))),
        ],
      ),
    );
  }
}

class _ModuleItem extends StatelessWidget {
  final String label, status;
  const _ModuleItem({required this.label, required this.status});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(Icons.description_outlined, size: 16, color: Colors.grey.withOpacity(0.8)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
          const Icon(Icons.check_circle, size: 14, color: Colors.green),
          const SizedBox(width: 6),
          Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _RecentSyncActivity extends StatelessWidget {
  const _RecentSyncActivity();

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
              const Expanded(child: Text('Recent Sync Activity', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              const Icon(Icons.refresh_rounded, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(flex: 2, child: Text('Time', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 3, child: Text('Device / Location', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 3, child: Text('Details', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 2, child: Text('Records', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 2, child: Text('Duration', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
            ],
          ),
          const SizedBox(height: 12),
          const _SyncRow(time: '10:30 AM', device: 'Main Store (This Device)', status: 'Success', details: 'All data synchronized', records: '1,256', duration: '00:00:24'),
          const _SyncRow(time: '10:15 AM', device: 'Warehouse', status: 'Success', details: 'All data synchronized', records: '842', duration: '00:00:18'),
          const _SyncRow(time: '10:00 AM', device: 'Branch Office', status: 'Success', details: 'All data synchronized', records: '1,105', duration: '00:00:21'),
          const _SyncRow(time: '09:45 AM', device: 'Main Store (This Device)', status: 'Success', details: 'All data synchronized', records: '1,023', duration: '00:00:17'),
          const _SyncRow(time: '09:30 AM', device: 'Warehouse', status: 'Success', details: 'All data synchronized', records: '754', duration: '00:00:16'),
          const SizedBox(height: 12),
          Center(child: TextButton(onPressed: () {}, child: const Text('View All Activity →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)))),
        ],
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  final String time, device, status, details, records, duration;
  const _SyncRow({required this.time, required this.device, required this.status, required this.details, required this.records, required this.duration});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.05)))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
          Expanded(flex: 3, child: Text(device, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
          Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(status, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.green))))),
          Expanded(flex: 3, child: Text(details, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
          Expanded(flex: 2, child: Text(records, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
          Expanded(flex: 2, child: Text(duration, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
        ],
      ),
    );
  }
}

class _SyncConflictsPanel extends StatelessWidget {
  const _SyncConflictsPanel();
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
              const Text('Sync Conflicts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)), child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(flex: 2, child: Text('Type', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 2, child: Text('Module', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 3, child: Text('Record', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 4, child: Text('Conflict', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              Expanded(flex: 3, child: Text('Detected On', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
              SizedBox(width: 80, child: Text('Action', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey))),
            ],
          ),
          const SizedBox(height: 12),
          const _ConflictRow(type: 'Update Conflict', module: 'Sales', record: 'Invoice #INV-10056', conflict: 'Record modified on multiple devices', date: 'May 24, 2025 10:28 AM'),
          const _ConflictRow(type: 'Delete Conflict', module: 'Product', record: 'Wireless Mouse', conflict: 'Record deleted on one device', date: 'May 24, 2025 10:20 AM'),
          const SizedBox(height: 12),
          TextButton(onPressed: () {}, child: const Text('View All Conflicts →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

class _ConflictRow extends StatelessWidget {
  final String type, module, record, conflict, date;
  const _ConflictRow({required this.type, required this.module, required this.record, required this.conflict, required this.date});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.05)))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(type, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.orange))),
          Expanded(flex: 2, child: Text(module, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
          Expanded(flex: 3, child: Text(record, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
          Expanded(flex: 4, child: Text(conflict, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
          Expanded(flex: 3, child: Text(date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
          SizedBox(width: 80, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF4F46E5), elevation: 0, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFF4F46E5)))), child: const Text('Resolve', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)))),
        ],
      ),
    );
  }
}

class _SyncRightRail extends StatelessWidget {
  const _SyncRightRail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ConnectedDevicesPanel(),
        SizedBox(height: 18),
        _SyncQuickActions(),
      ],
    );
  }
}

class _ConnectedDevicesPanel extends StatelessWidget {
  const _ConnectedDevicesPanel();
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
              const Expanded(child: Text('Connected Devices', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 18),
          const _DeviceItem(name: 'Main Store (This Device)', ip: 'Windows • 192.168.1.10', isCurrent: true),
          const _DeviceItem(name: 'Warehouse', ip: 'Windows • 192.168.1.20'),
          const _DeviceItem(name: 'Branch Office', ip: 'Android • 192.168.1.30'),
        ],
      ),
    );
  }
}

class _DeviceItem extends StatelessWidget {
  final String name, ip;
  final bool isCurrent;
  const _DeviceItem({required this.name, required this.ip, this.isCurrent = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.laptop_mac_outlined, size: 18, color: Colors.green)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), Text(ip, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600))])),
          if (isCurrent) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(6)), child: const Text('Current', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.blue))),
        ],
      ),
    );
  }
}

class _SyncQuickActions extends StatelessWidget {
  const _SyncQuickActions();
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
          const _QuickActionBtn(label: 'Sync Now', sub: 'Synchronize all data immediately', icon: Icons.sync_rounded, color: Colors.blue),
          const _QuickActionBtn(label: 'Resolve Conflicts', sub: 'View and resolve sync conflicts', icon: Icons.error_outline, color: Colors.orange),
          const _QuickActionBtn(label: 'Device Management', sub: 'Manage connected devices', icon: Icons.devices_outlined, color: Colors.indigo),
          const _QuickActionBtn(label: 'Sync Settings', sub: 'Configure sync preferences', icon: Icons.settings_outlined, color: Colors.purple),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final String label, sub;
  final IconData icon;
  final Color color;
  const _QuickActionBtn({required this.label, required this.sub, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.1))),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)), Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600))])),
              const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncInfoBanner extends StatelessWidget {
  const _SyncInfoBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.withOpacity(0.1))),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          const Expanded(child: Text('Keep your data synchronized. Sync Center helps keep all your devices and locations up to date. Ensure internet connection for smooth synchronization.', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600, height: 1.4))),
          const SizedBox(width: 16),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Learn More', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}
