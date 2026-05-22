import 'package:flutter/material.dart';

class UnitsTable extends StatelessWidget {
  const UnitsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> dummyUnits = [
      {'name': 'Pieces', 'abbr': 'pcs', 'type': 'Base Unit'},
      {'name': 'Kilograms', 'abbr': 'kg', 'type': 'Weight Unit'},
      {'name': 'Box (12)', 'abbr': 'box', 'type': 'Large Packing'},
      {'name': 'Grams', 'abbr': 'g', 'type': 'Small Packing'},
    ];

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
            child: Text('Units', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
            columns: const [
              DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataColumn(label: Text('Unit Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataColumn(label: Text('Abbreviation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            ],
            rows: List.generate(dummyUnits.length, (index) {
              final u = dummyUnits[index];
              return DataRow(cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(u['name']!, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(u['abbr']!)),
                DataCell(Text(u['type']!)),
                DataCell(Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () {}),
                  ],
                )),
              ]);
            }),
          ),
        ],
      ),
    );
  }
}
