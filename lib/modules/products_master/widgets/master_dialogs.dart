import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../controllers/products_master_controller.dart';
import '../../../database/database.dart';
import '../../../core/routes/app_routes.dart';

class MasterAddNewModal extends StatelessWidget {
  const MasterAddNewModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Entry',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select what you would like to add',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 32),
            _buildOption(
              icon: Icons.shopping_bag_rounded,
              title: 'Add Product',
              color: Colors.blue,
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.ADD_PRODUCT);
              },
            ),
            _buildOption(
              icon: Icons.category_rounded,
              title: 'Add Category',
              color: Colors.purple,
              onTap: () {
                Get.back();
                Get.dialog(const AddCategoryDialog());
              },
            ),
            _buildOption(
              icon: Icons.branding_watermark_rounded,
              title: 'Add Brand',
              color: Colors.orange,
              onTap: () {
                Get.back();
                Get.dialog(const AddBrandDialog());
              },
            ),
            _buildOption(
              icon: Icons.scale_rounded,
              title: 'Add Unit',
              color: Colors.green,
              onTap: () {
                Get.back();
                Get.dialog(const AddUnitDialog());
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade100),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class AddCategoryDialog extends StatefulWidget {
  final Category? category;
  const AddCategoryDialog({super.key, this.category});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _parent = TextEditingController();
  final _desc = TextEditingController();
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    if (widget.category != null) _name.text = widget.category!.name;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(widget.category == null ? 'New Category' : 'Edit Category', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(_name, 'Category Name', isRequired: true),
              const SizedBox(height: 12),
              _buildField(_parent, 'Parent Category (Optional)'),
              const SizedBox(height: 12),
              _buildField(_desc, 'Description', maxLines: 2),
              const SizedBox(height: 12),
              _buildDropdown('Status', ['Active', 'Inactive'], (v) => setState(() => _status = v!)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final controller = Get.find<ProductsMasterController>();
              if (widget.category == null) {
                await controller.db.into(controller.db.categories).insert(
                  CategoriesCompanion(
                    id: d.Value(controller.generateId()),
                    name: d.Value(_name.text),
                  )
                );
              } else {
                await controller.db.update(controller.db.categories).replace(widget.category!.copyWith(name: _name.text));
              }
              controller.refreshAll();
              Get.back();
            }
          }, 
          child: const Text('SAVE')
        ),
      ],
    );
  }
}

class AddBrandDialog extends StatefulWidget {
  final Brand? brand;
  const AddBrandDialog({super.key, this.brand});

  @override
  State<AddBrandDialog> createState() => _AddBrandDialogState();
}

class _AddBrandDialogState extends State<AddBrandDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _desc = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.brand != null) _name.text = widget.brand!.name;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(widget.brand == null ? 'New Brand' : 'Edit Brand', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(_name, 'Brand Name', isRequired: true),
              const SizedBox(height: 12),
              _buildField(_code, 'Brand Code'),
              const SizedBox(height: 12),
              _buildField(_desc, 'Description', maxLines: 2),
              const SizedBox(height: 12),
              _buildImagePicker('Brand Logo'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final controller = Get.find<ProductsMasterController>();
              if (widget.brand == null) {
                await controller.db.into(controller.db.brands).insert(
                  BrandsCompanion(
                    id: d.Value(controller.generateId()),
                    name: d.Value(_name.text),
                  )
                );
              } else {
                await controller.db.update(controller.db.brands).replace(widget.brand!.copyWith(name: _name.text));
              }
              controller.refreshAll();
              Get.back();
            }
          }, 
          child: const Text('SAVE')
        ),
      ],
    );
  }

  Widget _buildImagePicker(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Icon(Icons.add_photo_alternate_outlined, color: Colors.blue),
        ),
      ],
    );
  }
}

class AddUnitDialog extends StatefulWidget {
  const AddUnitDialog({super.key});

  @override
  State<AddUnitDialog> createState() => _AddUnitDialogState();
}

class _AddUnitDialogState extends State<AddUnitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _abbr = TextEditingController();
  String _type = 'Base Unit';
  bool _decimal = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('New Unit', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(_name, 'Unit Name', isRequired: true),
              const SizedBox(height: 12),
              _buildField(_abbr, 'Abbreviation', isRequired: true),
              const SizedBox(height: 12),
              _buildDropdown('Unit Type', ['Base Unit', 'Small Packing', 'Large Packing', 'Weight Unit'], (v) => setState(() => _type = v!)),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Allow Decimal', style: TextStyle(fontSize: 13)),
                value: _decimal,
                onChanged: (v) => setState(() => _decimal = v!),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Get.back();
            }
          }, 
          child: const Text('SAVE')
        ),
      ],
    );
  }
}

Widget _buildField(TextEditingController ctrl, String label, {bool isRequired = false, int maxLines = 1}) {
  return TextFormField(
    controller: ctrl,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    validator: isRequired ? (v) => v!.isEmpty ? 'Required' : null : null,
  );
}

Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
  return DropdownButtonFormField<String>(
    initialValue: items.first,
    items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14)))).toList(),
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
