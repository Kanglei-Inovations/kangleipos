import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Settings',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1280;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Sidebar: Settings Menu
              if (isDesktop) const SizedBox(width: 260, child: _SettingsMenuSidebar()),
              if (isDesktop) const SizedBox(width: 18),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const _BusinessProfileCard(),
                      const SizedBox(height: 18),
                      const _SettingsGrid(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsMenuSidebar extends StatelessWidget {
  const _SettingsMenuSidebar();

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'label': 'Business Settings', 'icon': Icons.business_outlined, 'selected': true},
      {'label': 'General Settings', 'icon': Icons.settings_outlined, 'selected': false},
      {'label': 'POS Settings', 'icon': Icons.point_of_sale_outlined, 'selected': false},
      {'label': 'Invoice Settings', 'icon': Icons.receipt_long_outlined, 'selected': false},
      {'label': 'Printer Settings', 'icon': Icons.print_outlined, 'selected': false},
      {'label': 'Payment Settings', 'icon': Icons.payments_outlined, 'selected': false},
      {'label': 'Notification Settings', 'icon': Icons.notifications_none_outlined, 'selected': false},
      {'label': 'User & Role Settings', 'icon': Icons.people_outline, 'selected': false},
      {'label': 'Backup Settings', 'icon': Icons.cloud_upload_outlined, 'selected': false},
      {'label': 'Security Settings', 'icon': Icons.security_outlined, 'selected': false},
      {'label': 'Integrations', 'icon': Icons.extension_outlined, 'selected': false},
      {'label': 'System Settings', 'icon': Icons.dns_outlined, 'selected': false},
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
                final isSelected = item['selected'] as bool;
                return InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4F46E5).withOpacity(0.1) : Colors.transparent,
                      border: Border(right: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent, width: 3)),
                    ),
                    child: Row(
                      children: [
                        Icon(item['icon'] as IconData, size: 18, color: isSelected ? const Color(0xFF4F46E5) : Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['label'] as String,
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
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.withOpacity(0.1))),
                      child: const Icon(Icons.store_outlined, size: 48, color: Colors.blue),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                child: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/QR_code_for_mobile_English_Wikipedia.svg/1200px-QR_code_for_mobile_English_Wikipedia.svg.png'),
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
  const _SettingsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      childAspectRatio: 1.8,
      children: const [
        _SettingsCard(title: 'General Settings', desc: 'Manage language, currency, date format and other preferences.', icon: Icons.settings_outlined, color: Colors.indigo, values: {'Language': 'English', 'Currency': 'INR (₹)', 'Date Format': 'DD-MM-YYYY'}),
        _SettingsCard(title: 'POS Settings', desc: 'Configure POS behavior, barcode, billing and checkout preferences.', icon: Icons.point_of_sale_outlined, color: Colors.blue, values: {'Default Customer': 'Walk-in Customer', 'Barcode Scanner': 'Enabled', 'Auto Print': 'Enabled'}),
        _SettingsCard(title: 'Invoice Settings', desc: 'Customize invoice appearance, terms, numbering and default values.', icon: Icons.receipt_long_outlined, color: Colors.purple, values: {'Invoice Prefix': 'INV-', 'Next Invoice No.': '10057', 'Due Days': '15 Days'}),
        _SettingsCard(title: 'Printer Settings', desc: 'Manage thermal printer, invoice printing and print templates.', icon: Icons.print_outlined, color: Colors.orange, values: {'Default Printer': 'Thermal Printer 1', 'Print Size': '80mm', 'Print Copies': '1'}),
        _SettingsCard(title: 'Tax & GST Settings', desc: 'Configure GST rates, tax preferences and default tax settings.', icon: Icons.account_balance_outlined, color: Colors.teal, values: {'Default GST Rate': '18%', 'Round Off': 'Enabled', 'Inclusive of Tax': 'No'}),
        _SettingsCard(title: 'Payment Settings', desc: 'Manage payment methods, defaults and card charges.', icon: Icons.payments_outlined, color: Colors.green, values: {'Default Payment': 'Cash', 'UPI ID': 'store@upi', 'Card Charges': '2.00%'}),
        _SettingsCard(title: 'Notification Settings', desc: 'Control email, SMS and in-app notification preferences.', icon: Icons.notifications_none_outlined, color: Colors.deepPurple, values: {'Email Notifications': 'Enabled', 'SMS Notifications': 'Enabled', 'Low Stock Alerts': 'Enabled'}),
        _SettingsCard(title: 'User & Role Settings', desc: 'Manage user access, roles and permissions.', icon: Icons.people_outline, color: Colors.blueGrey, values: {'Total Users': '12', 'Active Users': '5', 'Super Admin': '1'}),
        _SettingsCard(title: 'Backup Settings', desc: 'Manage data backup frequency and storage preferences.', icon: Icons.cloud_upload_outlined, color: Colors.blue, values: {'Auto Backup': 'Daily', 'Last Backup': 'May 24, 2025 02:30 AM', 'Backup Location': 'Google Drive'}),
        _SettingsCard(title: 'Security Settings', desc: 'Manage password policy, 2FA and login security.', icon: Icons.security_outlined, color: Colors.red, values: {'Two Factor Auth': 'Enabled', 'Password Expiry': '90 Days', 'Login Alerts': 'Enabled'}),
        _SettingsCard(title: 'Integrations', desc: 'Manage third party integrations and external services.', icon: Icons.extension_outlined, color: Colors.indigo, values: {'E-commerce': 'Connected', 'Accounting': 'Connected', 'SMS Gateway': 'Connected'}),
        _SettingsCard(title: 'System Settings', desc: 'Configure system behavior, performance and maintenance.', icon: Icons.dns_outlined, color: Colors.brown, values: {'Data Retention': '1 Year', 'System Logs': 'Enabled', 'Maintenance Mode': 'Disabled'}),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title, desc;
  final IconData icon;
  final Color color;
  final Map<String, String> values;

  const _SettingsCard({required this.title, required this.desc, required this.icon, required this.color, required this.values});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: color)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
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
    );
  }
}
