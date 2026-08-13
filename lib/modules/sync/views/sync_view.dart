import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/sync_controller.dart';

class SyncView extends StatelessWidget {
  const SyncView({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'Sync Center',
      child: SyncViewContent(),
    );
  }
}

class SyncViewContent extends StatelessWidget {
  const SyncViewContent({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SyncController>()) Get.put(SyncController());
    final controller = Get.find<SyncController>();
    final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return isDesktop
        ? const _DesktopSyncView()
        : const _MobileSyncView();
  }
}

// ─────────────────────────────────────────────────────────
// DESKTOP: Shows QR code + server controls
// ─────────────────────────────────────────────────────────
class _DesktopSyncView extends GetView<SyncController> {
  const _DesktopSyncView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info
          _SyncKpiRow(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // QR Panel
              Expanded(
                flex: 4,
                child: GlassPanel(
                  borderRadius: BorderRadius.circular(24),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Connect Mobile Device',
                          style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('Scan this QR code from the Kanglei POS mobile app to sync data.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black45)),
                      const SizedBox(height: 24),
                      Obx(() {
                        if (!controller.isServerRunning.value) {
                          return Column(
                            children: [
                              Icon(Icons.wifi_off_rounded, size: 64,
                                  color: isDark ? Colors.white30 : Colors.black26),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: controller.startDesktopServer,
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Start Sync Server'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: QrImageView(
                                data: controller.qrData.value,
                                version: QrVersions.auto,
                                size: 240,
                                eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Color(0xFF1E293B)),
                                dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Color(0xFF1E293B)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.circle,
                                      size: 8, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text('Server running on ${controller.localIp.value}:8765',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.green)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('Token: ${controller.serverToken.value}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white38 : Colors.black38,
                                    letterSpacing: 2)),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: controller.stopDesktopServer,
                              icon: const Icon(Icons.stop_rounded,
                                  color: Colors.red),
                              label: const Text('Stop Server',
                                  style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Instructions + Status
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _HowToConnectCard(),
                    const SizedBox(height: 16),
                    _SyncStatusCard(),
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

// ─────────────────────────────────────────────────────────
// MOBILE: Shows QR scanner + sync status
// ─────────────────────────────────────────────────────────
class _MobileSyncView extends GetView<SyncController> {
  const _MobileSyncView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MobileSyncStatusCard(),
          const SizedBox(height: 16),
          _MobileQrScanCard(),
          const SizedBox(height: 16),
          _MobileSyncActions(),
        ],
      ),
    );
  }
}

class _MobileSyncStatusCard extends GetView<SyncController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: controller.isConnected.value
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  controller.isConnected.value
                      ? Icons.wifi_rounded
                      : Icons.wifi_off_rounded,
                  color: controller.isConnected.value ? Colors.green : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.isConnected.value ? 'Connected to Desktop' : 'Not Connected',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Last sync: ${controller.lastSyncTime.value}',
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (controller.isSyncing.value) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: controller.syncProgress.value,
              backgroundColor: Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(controller.syncStatus.value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ] else if (controller.syncStatus.value.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(controller.syncStatus.value,
                style: TextStyle(
                    fontSize: 12,
                    color: controller.syncStatus.value.contains('✅')
                        ? Colors.green
                        : null)),
          ],
        ],
      )),
    );
  }
}

class _MobileQrScanCard extends StatefulWidget {
  @override
  State<_MobileQrScanCard> createState() => _MobileQrScanCardState();
}

class _MobileQrScanCardState extends State<_MobileQrScanCard> {
  final TextEditingController _ipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final syncCtrl = Get.find<SyncController>();

    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Connect to Desktop',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Scan the QR code shown on your desktop Kanglei POS app or enter PC IP',
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openScanner(context),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan Desktop QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('OR ENTER MANUAL IP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    hintText: '10.32.127.69 or 10.150.1.196',
                    labelText: 'Desktop IP',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final ip = _ipController.text.trim();
                  if (ip.isEmpty) return;
                  Get.snackbar('Connecting...', 'Connecting to $ip:8765...', duration: const Duration(seconds: 3));
                  final success = await syncCtrl.connectAndSync(ip, 8765, syncCtrl.serverToken.value);
                  if (success) {
                    Get.snackbar('Connected!', 'Successfully connected to PC ($ip)', backgroundColor: Colors.green, colorText: Colors.white);
                  } else {
                    Get.snackbar('Connection Failed', 'Could not reach $ip:8765. Ensure Windows Firewall port 8765 is allowed.', backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Connect'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openScanner(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const _QrScannerPage(),
    ));
  }
}

class _MobileSyncActions extends GetView<SyncController> {
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sync Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _SyncActionTile(
            icon: Icons.download_rounded,
            title: 'Pull from Desktop',
            subtitle: 'Download all products, suppliers, purchases',
            color: Colors.blue,
            onTap: () => controller.syncNow(),
          ),
          const SizedBox(height: 12),
          _SyncActionTile(
            icon: Icons.upload_rounded,
            title: 'Push to Desktop',
            subtitle: 'Upload mobile sales & purchases to desktop',
            color: Colors.green,
            onTap: () => controller.pushAllMobileDataToDesktop(),
          ),
        ],
      ),
    );
  }
}

class _SyncActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SyncActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: color)),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// QR Scanner Page (mobile only)
// ─────────────────────────────────────────────────────────
class _QrScannerPage extends StatefulWidget {
  const _QrScannerPage();

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  bool _scanned = false;
  final MobileScannerController _scannerCtrl = MobileScannerController();

  @override
  void dispose() {
    _scannerCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final ip = data['ip'] as String;
        final port = data['port'] as int;
        final token = data['token'] as String;

        setState(() => _scanned = true);
        await _scannerCtrl.stop();

        if (!mounted) return;
        Navigator.of(context).pop();

        // Connect and sync
        final controller = Get.find<SyncController>();
        final success = await controller.connectAndSync(ip, port, token);

        if (success) {
          Get.snackbar(
            '✅ Sync Complete',
            'Successfully connected to desktop and synced all data!',
            backgroundColor: Colors.green.withValues(alpha: 0.9),
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          // Navigate to dashboard
          Get.offAllNamed('/dashboard');
        } else {
          Get.snackbar(
            '❌ Sync Failed',
            'Could not connect to desktop. Make sure both devices are on the same WiFi.',
            backgroundColor: Colors.red.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
        }
        return;
      } catch (e) {
        Get.snackbar('Invalid QR', 'This QR code is not a valid sync code.');
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Desktop QR',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            onPressed: () => _scannerCtrl.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerCtrl,
            onDetect: _onDetect,
          ),
          // Overlay
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Icon(Icons.qr_code_scanner_rounded,
                    color: Colors.white54, size: 32),
                SizedBox(height: 12),
                Text(
                  'Point camera at the QR code\nshown on your desktop',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────
class _SyncKpiRow extends GetView<SyncController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = [
        _KpiData('Server', controller.isServerRunning.value ? 'Running' : 'Stopped',
            Icons.dns_rounded, controller.isServerRunning.value ? Colors.green : Colors.grey),
        _KpiData('IP Address', controller.localIp.value.isEmpty ? '...' : controller.localIp.value,
            Icons.router_rounded, Colors.blue),
        _KpiData('Port', '8765', Icons.lan_rounded, Colors.purple),
        _KpiData('Last Sync', controller.lastSyncTime.value,
            Icons.history_rounded, Colors.orange),
      ];

      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14,
        childAspectRatio: 2.8,
        children: stats.map((s) => _KpiCard(data: s)).toList(),
      );
    });
  }
}

class _KpiData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiData(this.title, this.value, this.icon, this.color);
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(data.icon, color: data.color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(data.title,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600)),
                Text(data.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowToConnectCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = [
      ('1', 'Open Kanglei POS on your Android phone'),
      ('2', 'On the login screen, tap "Scan QR to Connect"'),
      ('3', 'Point your camera at the QR code on the left'),
      ('4', 'Data will sync automatically and the app will open'),
    ];

    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How to Connect Mobile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ...steps.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(s.$1,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(s.$2,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _SyncStatusCard extends GetView<SyncController> {
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(24),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sync Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _StatusRow('Server', controller.isServerRunning.value ? 'Online' : 'Offline',
              controller.isServerRunning.value ? Colors.green : Colors.grey),
          _StatusRow('Connected Devices', '0', Colors.blue),
          _StatusRow('Last Sync', controller.lastSyncTime.value, Colors.orange),
        ],
      )),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ),
        ],
      ),
    );
  }
}
