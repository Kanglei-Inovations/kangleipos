import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../controllers/supplier_controller.dart';
import '../../../database/database.dart';

class AddSupplierDialog extends StatelessWidget {
  final Supplier? supplier;
  AddSupplierDialog({super.key, this.supplier});

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _gst = TextEditingController();
  final _balance = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (supplier != null) {
      _name.text = supplier!.name;
      _phone.text = supplier!.phone ?? '';
      _email.text = supplier!.email ?? '';
      _address.text = supplier!.address ?? '';
      _gst.text = supplier!.gstNumber ?? '';
      _balance.text = supplier!.balanceDue.toString();
    }

    return AlertDialog(
      title: Text(supplier == null ? 'Add Supplier' : 'Edit Supplier'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  controller: _name,
                  decoration:
                      const InputDecoration(labelText: 'Company/Supplier Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Phone Number')),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _email,
                  decoration:
                      const InputDecoration(labelText: 'Email Address')),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(labelText: 'Address')),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _gst,
                  decoration: const InputDecoration(labelText: 'GST Number')),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _balance,
                  decoration: const InputDecoration(
                      labelText: 'Credit Balance (Opening)'),
                  keyboardType: TextInputType.number),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
        ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final controller = Get.find<SupplierController>();
                if (supplier == null) {
                  controller.addSupplier(
                    name: _name.text,
                    phone: _phone.text,
                    email: _email.text,
                    address: _address.text,
                    gst: _gst.text,
                    openingBalance: double.tryParse(_balance.text) ?? 0,
                  );
                } else {
                  controller.updateSupplier(supplier!.copyWith(
                    name: _name.text,
                    phone: d.Value(_phone.text.isEmpty ? null : _phone.text),
                    email: d.Value(_email.text.isEmpty ? null : _email.text),
                    address:
                        d.Value(_address.text.isEmpty ? null : _address.text),
                    gstNumber: d.Value(_gst.text.isEmpty ? null : _gst.text),
                    balanceDue: double.tryParse(_balance.text) ?? 0,
                  ));
                }
                Get.back();
              }
            },
            child: Text(supplier == null ? 'SAVE' : 'UPDATE')),
      ],
    );
  }
}
