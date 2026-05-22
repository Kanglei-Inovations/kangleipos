import 'package:flutter/material.dart';

class UnitsTable extends StatelessWidget {
  final List<Map<String, String>> units;

  const UnitsTable({super.key, required this.units});

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
            child: Text('Units', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
              columns: const [
                DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Unit Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Abbreviation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: List.generate(units.length, (index) {
                final u = units[index];
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
          ),
        ],
      ),
    );
  }
}
