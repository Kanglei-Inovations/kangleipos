import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../controllers/customer_controller.dart';
import '../../../database/database.dart';

class AddCustomerDialog extends StatelessWidget {
  final Customer? customer;
  AddCustomerDialog({super.key, this.customer});

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _gst = TextEditingController();
  final _balance = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (customer != null) {
      _name.text = customer!.name;
      _phone.text = customer!.phone ?? '';
      _email.text = customer!.email ?? '';
      _address.text = customer!.address ?? '';
      _gst.text = customer!.gstNumber ?? '';
      _balance.text = customer!.balanceDue.toString();
    }

    return AlertDialog(
      title: Text(customer == null ? 'Add Customer' : 'Edit Customer'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Full Name'),
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
                  decoration:
                      const InputDecoration(labelText: 'Opening Balance (Due)'),
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
                final controller = Get.find<CustomerController>();
                if (customer == null) {
                  controller.addCustomer(
                    name: _name.text,
                    phone: _phone.text,
                    email: _email.text,
                    address: _address.text,
                    gst: _gst.text,
                    openingBalance: double.tryParse(_balance.text) ?? 0,
                  );
                } else {
                  controller.updateCustomer(customer!.copyWith(
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
            child: Text(customer == null ? 'SAVE' : 'UPDATE')),
      ],
    );
  }
}
