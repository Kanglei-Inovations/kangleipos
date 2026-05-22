import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final name = TextEditingController(text: controller.businessName.value);
    final addr = TextEditingController(text: controller.address.value);
    final gst = TextEditingController(text: controller.gst.value);
    final RxInt timeout = controller.sessionTimeout.value.obs;

    return MainLayout(
      title: 'Settings',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Business Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Get.theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    TextField(controller: name, decoration: const InputDecoration(labelText: 'Business Name')),
                    const SizedBox(height: 16),
                    TextField(controller: addr, decoration: const InputDecoration(labelText: 'Address'), maxLines: 2),
                    const SizedBox(height: 16),
                    TextField(controller: gst, decoration: const InputDecoration(labelText: 'GST Number')),
                    const SizedBox(height: 32),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Security Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Auto-lock timeout: ${timeout.value} mins'),
                          ],
                        ),
                        Slider(
                          value: timeout.value.toDouble(),
                          min: 5,
                          max: 60,
                          divisions: 11,
                          onChanged: (v) => timeout.value = v.toInt(),
                        ),
                      ],
                    )),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.saveSettings(
                          name: name.text,
                          addr: addr.text,
                          gstNo: gst.text,
                          timeout: timeout.value,
                        ),
                        child: const Text('SAVE SETTINGS'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildDangerZone(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Danger Zone', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Deleting your local data is permanent. Make sure you have a backup.', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
            child: const Text('RESET ALL DATA'),
          ),
        ],
      ),
    );
  }
}
