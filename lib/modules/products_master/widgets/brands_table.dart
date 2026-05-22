import 'package:flutter/material.dart';
import '../../../database/database.dart';

class BrandsTable extends StatelessWidget {
  final List<Brand> brands;

  const BrandsTable({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Brands', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
              columns: const [
                DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Brand Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Products', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: List.generate(brands.length, (index) {
                final b = brands[index];
                return DataRow(cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                  const DataCell(Text('-')),
                  const DataCell(Text('0')),
                  DataCell(_statusChip('Active', Colors.green)),
                  DataCell(Row(
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () {}),
                    ],
                  )),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
