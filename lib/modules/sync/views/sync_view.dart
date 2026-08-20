import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/routes/app_routes.dart';
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
    if (!Get.isRegistered<SyncController>()) Get.put(SyncController());
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
      builder: (_) => const QrScannerPage(),
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
// QR Scanner & Connection Page (3-Step Animated Flow)
// ─────────────────────────────────────────────────────────
class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

enum _ConnectionStep { scanning, connecting, connected, failed }

class _QrScannerPageState extends State<QrScannerPage> with SingleTickerProviderStateMixin {
  _ConnectionStep _step = _ConnectionStep.scanning;
  final MobileScannerController _scannerCtrl = MobileScannerController();
  late final AnimationController _animCtrl;
  
  bool _torchOn = false;
  String _connectedIp = '';
  String _connectedTime = '';
  String _errorMessage = '';
  int _connectionProgressIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SyncController>()) {
      Get.put(SyncController());
    }
    _animCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _scannerCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_step != _ConnectionStep.scanning) return;
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final ip = data['ip'] as String;
        final port = data['port'] as int;
        final token = data['token'] as String;

        await _scannerCtrl.stop();
        _startConnectionFlow(ip, port, token);
        return;
      } catch (e) {
        // Invalid format
      }
    }
  }

  void _startConnectionFlow(String ip, int port, String token) async {
    setState(() {
      _step = _ConnectionStep.connecting;
      _connectedIp = ip;
      _connectionProgressIndex = 1;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _connectionProgressIndex = 2);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _connectionProgressIndex = 3);

    final syncCtrl = Get.isRegistered<SyncController>() ? Get.find<SyncController>() : Get.put(SyncController());
    final success = await syncCtrl.connectAndSync(ip, port, token);

    if (!mounted) return;
    if (success) {
      final now = DateTime.now();
      setState(() {
        _step = _ConnectionStep.connected;
        _connectedTime = '${DateFormat('dd MMM yyyy, hh:mm a').format(now)}';
      });
    } else {
      setState(() {
        _step = _ConnectionStep.failed;
        _errorMessage = 'Could not reach Desktop at $ip:$port. Ensure both devices are on the same Wi-Fi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _ConnectionStep.connecting) {
      return _buildConnectingScreen();
    } else if (_step == _ConnectionStep.connected) {
      return _buildConnectedScreen();
    } else if (_step == _ConnectionStep.failed) {
      return _buildFailedScreen();
    }
    return _buildScannerScreen();
  }

  // 1. SCANNER SCREEN (Dark mode, neon corner brackets, instructions)
  Widget _buildScannerScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan to Connect',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            const Text(
              'Scan the QR code from your\ncomputer to connect',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),

            // Scanner Frame
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.6), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MobileScanner(
                        controller: _scannerCtrl,
                        onDetect: _onDetect,
                      ),
                      // Animated scanning line
                      AnimatedBuilder(
                        animation: _animCtrl,
                        builder: (context, _) {
                          return Positioned(
                            top: 20 + _animCtrl.value * 230,
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.transparent, Color(0xFF6366F1), Color(0xFF38BDF8), Colors.transparent],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Flashlight button
            InkWell(
              onTap: () {
                _scannerCtrl.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_torchOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(_torchOn ? 'Tap to turn off light' : 'Tap to turn on light', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // How to connect card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('How to connect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 14),
                  _buildInstructionRow('1', 'Open Kanglei Store ERP on your computer'),
                  _buildInstructionRow('2', 'Go to Settings > Mobile Sync'),
                  _buildInstructionRow('3', 'Scan the QR code to connect'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your connection is encrypted and secure.',
              style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionRow(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFF4F46E5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3)),
          ),
        ],
      ),
    );
  }

  // 2. CONNECTING SCREEN
  Widget _buildConnectingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => setState(() => _step = _ConnectionStep.scanning),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text('Connecting...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            const Text('Establishing secure connection', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            const SizedBox(height: 48),

            // Animated Rotating Icon
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: RotationTransition(
                    turns: _animCtrl,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sync_rounded, color: Colors.white, size: 38),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 52),

            // Steps Checklist Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildStepRow('Scanning QR code', _connectionProgressIndex >= 1),
                  const SizedBox(height: 14),
                  _buildStepRow('Verifying connection', _connectionProgressIndex >= 2),
                  const SizedBox(height: 14),
                  _buildStepRow('Establishing secure link', _connectionProgressIndex >= 3),
                  const SizedBox(height: 14),
                  _buildStepRow('Syncing data', _connectionProgressIndex >= 4),
                ],
              ),
            ),
            const Spacer(),
            const Text('Please wait while we connect you...', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String title, bool isDone) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: isDone ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
              color: isDone ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
            ),
          ),
        ),
        if (isDone)
          const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 18)
        else
          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5))),
      ],
    );
  }

  // 3. CONNECTED SUCCESSFULLY SCREEN
  Widget _buildConnectedScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Get.offAllNamed(AppRoutes.DASHBOARD),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text('Connected Successfully!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            const Text('You are now connected to Kanglei POS', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            const SizedBox(height: 36),

            // Big Green Checkmark with Concentric Pulsing Rings
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Connection Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Connection Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                  const SizedBox(height: 16),
                  _buildDetailRow('Store Name', 'Main Store'),
                  const SizedBox(height: 10),
                  _buildDetailRow('Connected Device', 'DESKTOP-POS ($_connectedIp)'),
                  const SizedBox(height: 10),
                  _buildDetailRow('Connected At', _connectedTime.isEmpty ? 'Just Now' : _connectedTime),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: Color(0xFF10B981), size: 6),
                            SizedBox(width: 5),
                            Text('Active', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Go to Dashboard Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.DASHBOARD),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Go to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
      ],
    );
  }

  // 4. FAILED SCREEN
  Widget _buildFailedScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => setState(() => _step = _ConnectionStep.scanning),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 44),
            ),
            const SizedBox(height: 20),
            const Text('Connection Failed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            const SizedBox(height: 10),
            Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _step = _ConnectionStep.scanning);
                  _scannerCtrl.start();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Try Again', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
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
