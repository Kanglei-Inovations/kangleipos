import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/user_controller.dart';

class UserView extends GetView<UserController> {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'User Management',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(child: _buildUserList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Staff & Roles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Manage system access and permissions.', style: TextStyle(color: Colors.grey)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddUserDialog(),
          icon: const Icon(Icons.person_add),
          label: const Text('ADD NEW STAFF'),
        ),
      ],
    );
  }

  Widget _buildUserList() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.users.isEmpty) return const Center(child: Text('No staff accounts found.'));

        return ListView.separated(
          itemCount: controller.users.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = controller.users[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: user.role == 'ADMIN' ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                child: Icon(user.role == 'ADMIN' ? Icons.admin_panel_settings : Icons.person, color: user.role == 'ADMIN' ? Colors.blue : Colors.green),
              ),
              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${user.username} • ${user.role}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(user),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddUserDialog() {
    final name = TextEditingController();
    final username = TextEditingController();
    final pin = TextEditingController();
    String role = 'CASHIER';

    Get.defaultDialog(
      title: 'Add Staff Account',
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextField(controller: username, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 12),
            TextField(controller: pin, decoration: const InputDecoration(labelText: '4-Digit PIN'), maxLength: 4, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                DropdownMenuItem(value: 'MANAGER', child: Text('Manager')),
                DropdownMenuItem(value: 'CASHIER', child: Text('Cashier')),
              ],
              onChanged: (v) => role = v!,
              decoration: const InputDecoration(labelText: 'System Role'),
            ),
          ],
        ),
      ),
      textConfirm: 'CREATE',
      textCancel: 'CANCEL',
      onConfirm: () {
        controller.addUser(name: name.text, username: username.text, pin: pin.text, role: role);
        Get.back();
      },
    );
  }

  void _confirmDelete(dynamic user) {
    Get.defaultDialog(
      title: 'Delete User',
      middleText: 'Are you sure you want to remove ${user.name}?',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteUser(user.id);
        Get.back();
      },
    );
  }
}
