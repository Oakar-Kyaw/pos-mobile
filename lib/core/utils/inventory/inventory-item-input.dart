import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/localization/inventory-management-local.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InventoryItemInput extends ConsumerWidget {
  const InventoryItemInput({
    super.key,
    required this.index,
    required this.itemName,
    required this.price,
    required this.controller,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.validator,
  });

  final int index;

  final String itemName;

  final TextEditingController controller;

  final ValueChanged<String> onQuantityChanged;

  final double price;

  final VoidCallback onRemove;

  final String? Function(String v) validator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(itemName, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 5),
          Expanded(
            child: ShadInputFormField(
              id: 'inventory_$index',
              validator: (v) => validator(v),
              controller: controller,
              keyboardType: TextInputType.number,
              onChanged: onQuantityChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Text(
                  InventoryManagementLocale.inventorySellingPrice.getString(
                    context,
                  ),
                ),
                Text(
                  price.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(LucideIcons.trash2, color: Colors.redAccent),
            tooltip: 'Remove',
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
