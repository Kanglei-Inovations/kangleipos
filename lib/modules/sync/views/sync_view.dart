import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/sync_controller.dart';

class SyncView extends GetView<SyncController> {
  const SyncView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Sync Center (LAN)',
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          children: [
            Expanded(child: _buildHostPanel()),
            const SizedBox(width: 32),
            Expanded(child: _buildClientPanel()),
          ],
        ),
      ),
    );
  }

  Widget _buildHostPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.dns_outlined, size: 64, color: Colors.blue),
          const SizedBox(height: 24),
          const Text('Run as Host (Desktop)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Use this if this computer is your main billing terminal.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          Obx(() => Text('Your IP: ${controller.localIp.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          const Spacer(),
          Obx(() => ElevatedButton(
            onPressed: controller.isServerRunning.value ? null : () => controller.startHost(),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
            child: Text(controller.isServerRunning.value ? 'SERVER RUNNING' : 'START SYNC SERVER'),
          )),
        ],
      ),
    );
  }

  Widget _buildClientPanel() {
    final ipCtrl = TextEditingController();
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.phonelink_ring_outlined, size: 64, color: Colors.green),
          const SizedBox(height: 24),
          const Text('Connect as Client (Mobile)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Use this to connect mobile devices to the main terminal.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          TextField(
            controller: ipCtrl,
            decoration: const InputDecoration(labelText: 'Host IP Address', hintText: 'e.g. 192.168.1.5'),
          ),
          const Spacer(),
          Obx(() => ElevatedButton(
            onPressed: controller.isClientConnected.value ? null : () => controller.connectToHost(ipCtrl.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 56)),
            child: Text(controller.isClientConnected.value ? 'CONNECTED' : 'CONNECT TO HOST'),
          )),
        ],
      ),
    );
  }
}
