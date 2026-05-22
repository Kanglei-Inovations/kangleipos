import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../controllers/auth_controller.dart';

class SetupView extends GetView<AuthController> {
  SetupView({super.key});

  final _formKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();
  final _address = TextEditingController();
  final _gst = TextEditingController();
  final _adminName = TextEditingController();
  final _adminPin = TextEditingController();
  final RxInt _timeout = 15.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ScreenTypeLayout.builder(
            mobile: (context) => _buildSetupForm(context, width: double.infinity),
            desktop: (context) => _buildSetupForm(context, width: 600),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupForm(BuildContext context, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.rocket_launch_rounded, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Welcome to KANGLEI POS',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete the initial setup to get started',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),
            
            _sectionTitle('Business Identity'),
            const SizedBox(height: 16),
            _buildTextField(_businessName, 'Business Name', Icons.business, isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(_address, 'Business Address', Icons.location_on_outlined),
            const SizedBox(height: 16),
            _buildTextField(_gst, 'GST Number (Optional)', Icons.receipt_long_outlined),
            
            const SizedBox(height: 32),
            _sectionTitle('Security & Admin'),
            const SizedBox(height: 16),
            _buildTextField(_adminName, 'Owner/Admin Name', Icons.person_outline, isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(_adminPin, 'Login PIN (4-Digits)', Icons.dialpad, isRequired: true, isNumber: true, maxLength: 4),
            
            const SizedBox(height: 32),
            _sectionTitle('Session Settings'),
            const SizedBox(height: 8),
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Auto-lock timeout: ${_timeout.value} minutes', style: const TextStyle(fontSize: 14)),
                Slider(
                  value: _timeout.value.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  label: '${_timeout.value} mins',
                  onChanged: (v) => _timeout.value = v.toInt(),
                ),
                const Text('App will ask for PIN after this period of inactivity.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            )),

            const SizedBox(height: 48),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
              child: controller.isLoading.value 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('FINISH SETUP & START', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 1.2));
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isRequired = false, bool isNumber = false, int? maxLength}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        counterText: '',
      ),
      validator: (v) {
        if (isRequired && (v == null || v.isEmpty)) return 'This field is required';
        if (isNumber && v != null && v.length != maxLength) return 'Must be $maxLength digits';
        return null;
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      controller.completeSetup(
        businessName: _businessName.text,
        address: _address.text,
        gst: _gst.text,
        adminName: _adminName.text,
        adminPin: _adminPin.text,
        timeout: _timeout.value,
      );
    }
  }
}
