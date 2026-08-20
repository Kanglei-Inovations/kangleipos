import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../backup/views/backup_view.dart';
import '../../sync/controllers/sync_controller.dart';
import '../../sync/views/sync_view.dart';
import '../../users/views/user_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String _activeTab = 'Business Settings';

  void _selectTab(String tabLabel) {
    setState(() {
      _activeTab = tabLabel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Settings',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          final isDesktop = constraints.maxWidth >= 1280;

          if (isMobile) {
            if (_activeTab != 'Business Settings') {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SettingsSubHeader(
                    title: _activeTab,
                    onBack: () => _selectTab('Business Settings'),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildActiveTabContent()),
                ],
              );
            }
            return _MobileSettingsView(onSelectTab: _selectTab);
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Sidebar: Settings Menu
              if (isDesktop)
                SizedBox(
                  width: 260,
                  child: _SettingsMenuSidebar(
                    activeTab: _activeTab,
                    onSelectTab: _selectTab,
                  ),
                ),
              if (isDesktop) const SizedBox(width: 18),

              // Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_activeTab != 'Business Settings') ...[
                      _SettingsSubHeader(
                        title: _activeTab,
                        onBack: () => _selectTab('Business Settings'),
                      ),
                      const SizedBox(height: 14),
                    ],
                    Expanded(
                      child: _buildActiveTabContent(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 'User & Role Settings':
        return const UserViewContent();
      case 'Backup Settings':
        return const BackupViewContent();
      case 'Sync Settings':
        return const SyncViewContent();
      case 'Business Settings':
      default:
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              const _BusinessProfileCard(),
              const SizedBox(height: 18),
              _SettingsGrid(onSelectCard: _selectTab),
              const SizedBox(height: 24),
            ],
          ),
        );
    }
  }
}

class _SettingsSubHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _SettingsSubHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_rounded, size: 16, color: Colors.indigo),
                  SizedBox(width: 6),
                  Text(
                    'Back to Overview',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _SettingsMenuSidebar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onSelectTab;

  const _SettingsMenuSidebar({
    required this.activeTab,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'label': 'Business Settings', 'icon': Icons.business_outlined},
      {'label': 'User & Role Settings', 'icon': Icons.people_outline},
      {'label': 'Backup Settings', 'icon': Icons.cloud_upload_outlined},
      {'label': 'Sync Settings', 'icon': Icons.sync_rounded},
      {'label': 'General Settings', 'icon': Icons.settings_outlined},
      {'label': 'POS Settings', 'icon': Icons.point_of_sale_outlined},
      {'label': 'Invoice Settings', 'icon': Icons.receipt_long_outlined},
      {'label': 'Printer Settings', 'icon': Icons.print_outlined},
      {'label': 'Payment Settings', 'icon': Icons.payments_outlined},
      {'label': 'Notification Settings', 'icon': Icons.notifications_none_outlined},
      {'label': 'Security Settings', 'icon': Icons.security_outlined},
      {'label': 'Integrations', 'icon': Icons.extension_outlined},
      {'label': 'System Settings', 'icon': Icons.dns_outlined},
    ];

    return Column(
      children: [
        GlassPanel(
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Settings Menu', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
              const SizedBox(height: 12),
              ...menuItems.map((item) {
                final label = item['label'] as String;
                final isSelected = activeTab == label;
                return InkWell(
                  onTap: () => onSelectTab(label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4F46E5).withValues(alpha: 0.1) : Colors.transparent,
                      border: Border(right: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent, width: 3)),
                    ),
                    child: Row(
                      children: [
                        Icon(item['icon'] as IconData, size: 18, color: isSelected ? const Color(0xFF4F46E5) : Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
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
              }),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _NeedHelpCard(),
      ],
    );
  }
}

class _NeedHelpCard extends StatelessWidget {
  const _NeedHelpCard();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Need Help?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('If you need any help with settings, please contact our support team.', style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.headset_mic_outlined, size: 16),
              label: const Text('Contact Support', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4F46E5),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFF4F46E5))),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessProfileCard extends StatelessWidget {
  const _BusinessProfileCard();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Business Settings', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit Business Info', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Manage your business profile and primary information', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.withValues(alpha: 0.1))),
                      child: const Icon(Icons.store_outlined, size: 48, color: Colors.blue),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(
                      child: Wrap(
                        runSpacing: 24,
                        children: [
                          _ProfileInfo(label: 'Business Name', value: 'Main Store'),
                          _ProfileInfo(label: 'Email', value: 'info@mainstore.com'),
                          _ProfileInfo(label: 'Business Type', value: 'Retail'),
                          _ProfileInfo(label: 'Address', value: '123, Market Street, Connaught Place,\nNew Delhi - 110001, India'),
                          _ProfileInfo(label: 'Phone', value: '+91 98765 43210'),
                          _ProfileInfo(label: 'GSTIN', value: '07ABCDE1234F1Z5'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Column(
            children: [
              Container(
                width: 120, height: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
                child: const Icon(Icons.qr_code_2_rounded, size: 90, color: Colors.indigo),
              ),
              const SizedBox(height: 8),
              const Text('Store QR Code', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final String label, value;
  const _ProfileInfo({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SettingsGrid extends StatelessWidget {
  final ValueChanged<String> onSelectCard;

  const _SettingsGrid({required this.onSelectCard});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      childAspectRatio: 1.8,
      children: [
        _SettingsCard(
          title: 'General Settings',
          desc: 'Manage language, currency, date format and other preferences.',
          icon: Icons.settings_outlined,
          color: Colors.indigo,
          onTap: () => onSelectCard('General Settings'),
          values: const {'Language': 'English', 'Currency': 'INR (₹)', 'Date Format': 'DD-MM-YYYY'},
        ),
        _SettingsCard(
          title: 'POS Settings',
          desc: 'Configure POS behavior, barcode, billing and checkout preferences.',
          icon: Icons.point_of_sale_outlined,
          color: Colors.blue,
          onTap: () => onSelectCard('POS Settings'),
          values: const {'Default Customer': 'Walk-in Customer', 'Barcode Scanner': 'Enabled', 'Auto Print': 'Enabled'},
        ),
        _SettingsCard(
          title: 'Invoice Settings',
          desc: 'Customize invoice appearance, terms, numbering and default values.',
          icon: Icons.receipt_long_outlined,
          color: Colors.purple,
          onTap: () => onSelectCard('Invoice Settings'),
          values: const {'Invoice Prefix': 'INV-', 'Next Invoice No.': '10057', 'Due Days': '15 Days'},
        ),
        _SettingsCard(
          title: 'Printer Settings',
          desc: 'Manage thermal printer, invoice printing and print templates.',
          icon: Icons.print_outlined,
          color: Colors.orange,
          onTap: () => onSelectCard('Printer Settings'),
          values: const {'Default Printer': 'Thermal Printer 1', 'Print Size': '80mm', 'Print Copies': '1'},
        ),
        _SettingsCard(
          title: 'Tax & GST Settings',
          desc: 'Configure GST rates, tax preferences and default tax settings.',
          icon: Icons.account_balance_outlined,
          color: Colors.teal,
          onTap: () => onSelectCard('Tax & GST Settings'),
          values: const {'Default GST Rate': '18%', 'Round Off': 'Enabled', 'Inclusive of Tax': 'No'},
        ),
        _SettingsCard(
          title: 'Payment Settings',
          desc: 'Manage payment methods, defaults and card charges.',
          icon: Icons.payments_outlined,
          color: Colors.green,
          onTap: () => onSelectCard('Payment Settings'),
          values: const {'Default Payment': 'Cash', 'UPI ID': 'store@upi', 'Card Charges': '2.00%'},
        ),
        _SettingsCard(
          title: 'Notification Settings',
          desc: 'Control email, SMS and in-app notification preferences.',
          icon: Icons.notifications_none_outlined,
          color: Colors.deepPurple,
          onTap: () => onSelectCard('Notification Settings'),
          values: const {'Email Notifications': 'Enabled', 'SMS Notifications': 'Enabled', 'Low Stock Alerts': 'Enabled'},
        ),
        _SettingsCard(
          title: 'User & Role Settings',
          desc: 'Manage user access, staff roles and permissions.',
          icon: Icons.people_outline,
          color: Colors.blueGrey,
          onTap: () => onSelectCard('User & Role Settings'),
          values: const {'Total Users': '12', 'Active Users': '5', 'Super Admin': '1'},
        ),
        _SettingsCard(
          title: 'Backup Settings',
          desc: 'Manage data backup frequency, archives and restores.',
          icon: Icons.cloud_upload_outlined,
          color: Colors.blue,
          onTap: () => onSelectCard('Backup Settings'),
          values: const {'Auto Backup': 'Daily', 'Last Backup': 'May 24, 2025 02:30 AM', 'Backup Location': 'Local Storage'},
        ),
        _SettingsCard(
          title: 'Sync Settings',
          desc: 'Manage multi-device LAN synchronization and terminal pairings.',
          icon: Icons.sync_rounded,
          color: Colors.teal,
          onTap: () => onSelectCard('Sync Settings'),
          values: const {'Sync Mode': 'Server & Client', 'Connected Terminals': '3', 'Port': '8080'},
        ),
        _SettingsCard(
          title: 'Security Settings',
          desc: 'Manage password policy, 2FA and login security.',
          icon: Icons.security_outlined,
          color: Colors.red,
          onTap: () => onSelectCard('Security Settings'),
          values: const {'Two Factor Auth': 'Enabled', 'Password Expiry': '90 Days', 'Login Alerts': 'Enabled'},
        ),
        _SettingsCard(
          title: 'Integrations',
          desc: 'Manage third party integrations and external services.',
          icon: Icons.extension_outlined,
          color: Colors.indigo,
          onTap: () => onSelectCard('Integrations'),
          values: const {'E-commerce': 'Connected', 'Accounting': 'Connected', 'SMS Gateway': 'Connected'},
        ),
        _SettingsCard(
          title: 'System Settings',
          desc: 'Configure system behavior, performance and maintenance.',
          icon: Icons.dns_outlined,
          color: Colors.brown,
          onTap: () => onSelectCard('System Settings'),
          values: const {'Data Retention': '1 Year', 'System Logs': 'Enabled', 'Maintenance Mode': 'Disabled'},
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title, desc;
  final IconData icon;
  final Color color;
  final Map<String, String> values;
  final VoidCallback? onTap;

  const _SettingsCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.values,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: GlassPanel(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, size: 16, color: color),
                        ],
                      ),
                      Text(desc, style: const TextStyle(fontSize: 9, color: Colors.grey, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            ...values.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)),
                    Text(e.value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// MOBILE SETTINGS VIEW (Matching Screen 8)
// ─────────────────────────────────────────────────────────
class _MobileSettingsView extends StatelessWidget {
  final ValueChanged<String> onSelectTab;

  const _MobileSettingsView({required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SyncController>()) Get.put(SyncController());
    final syncCtrl = Get.find<SyncController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. SYNC MANAGEMENT CARD
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sync Management',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                // Sync Status
                Obx(() => Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wifi_rounded, size: 16, color: Color(0xFF4F46E5)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sync Status',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: syncCtrl.isConnected.value
                            ? const Color(0xFF10B981).withValues(alpha: 0.12)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        syncCtrl.isConnected.value ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          color: syncCtrl.isConnected.value ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 12),
                // Last Sync
                Obx(() => Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF4F46E5)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Last Sync',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    Text(
                      syncCtrl.lastSyncTime.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 12),
                // Auto Sync
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sync_rounded, size: 16, color: Color(0xFF4F46E5)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Auto Sync',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Every 5 Minutes',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, size: 16, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Scan QR Action Tile
                _buildActionTile(
                  icon: Icons.qr_code_scanner_rounded,
                  title: 'Scan QR Code',
                  subtitle: 'Connect or pair with Desktop PC',
                  color: const Color(0xFF4F46E5),
                  isDark: isDark,
                  onTap: () => Get.to(() => const QrScannerPage()),
                ),
                const SizedBox(height: 14),
                // Action Buttons: Pull Data & Push Data
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: Obx(() => ElevatedButton.icon(
                          onPressed: (syncCtrl.isPulling.value || syncCtrl.isPushing.value) ? null : () => syncCtrl.syncNow(),
                          icon: syncCtrl.isPulling.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Pull Data', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: Obx(() => OutlinedButton.icon(
                          onPressed: (syncCtrl.isPulling.value || syncCtrl.isPushing.value)
                              ? null
                              : () async {
                                  await syncCtrl.pushAllMobileDataToDesktop();
                                },
                          icon: syncCtrl.isPushing.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.upload_rounded, size: 18),
                          label: const Text('Push Data', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF58E18F),
                            foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                            side: BorderSide(
                              color: isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFE2E8F0),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. CONNECTION MANAGEMENT CARD
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection Management',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                _buildActionTile(
                  icon: Icons.print_outlined,
                  title: 'Printer Settings',
                  subtitle: 'Configure printer connection',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _buildActionTile(
                  icon: Icons.devices_outlined,
                  title: 'Connected Devices',
                  subtitle: '1 Active Device',
                  color: const Color(0xFF0EA5E9),
                  isDark: isDark,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. APP SETTINGS CARD
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                _buildActionTile(
                  icon: Icons.settings_outlined,
                  title: 'General Settings',
                  subtitle: 'App preferences & theme',
                  color: const Color(0xFF8B5CF6),
                  isDark: isDark,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _buildActionTile(
                  icon: Icons.people_outline_rounded,
                  title: 'User & Role Settings',
                  subtitle: 'Manage user access',
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                  onTap: () => onSelectTab('User & Role Settings'),
                ),
                const SizedBox(height: 8),
                _buildActionTile(
                  icon: Icons.backup_outlined,
                  title: 'Backup & Restore',
                  subtitle: 'Database backups',
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                  onTap: () => onSelectTab('Backup Settings'),
                ),
                const SizedBox(height: 8),
                _buildActionTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  subtitle: 'Sign out of current account',
                  color: const Color(0xFFEF4444),
                  isDark: isDark,
                  onTap: () {
                    if (Get.isRegistered<AuthController>()) {
                      Get.find<AuthController>().logout();
                    } else {
                      Get.offAllNamed('/auth');
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

