import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactListView<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final bool isLoading;
  final Function(String) onSearch;
  final Function() onAdd;
  final Widget Function(T) itemBuilder;

  const ContactListView({
    super.key,
    required this.title,
    required this.items,
    required this.isLoading,
    required this.onSearch,
    required this.onAdd,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search $title...',
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Get.theme.cardColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.person_add_alt_1),
                label: Text('ADD ${title.toUpperCase()}'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? Center(child: Text('No $title found.'))
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) => itemBuilder(items[index]),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
