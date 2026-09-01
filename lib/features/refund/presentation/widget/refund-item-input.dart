import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RefundItemInput extends ConsumerWidget {
  const RefundItemInput({
    super.key,
    required this.index,
    required this.itemName,
    required this.price,
    required this.controller,
    required this.onAmountChanged,
    required this.onRemove,
    required this.validator,
  });

  final int index;

  final String itemName;

  final TextEditingController controller;

  final ValueChanged<String> onAmountChanged;

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
          Expanded(
            flex: 4,
            child: Text(itemName, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: ShadInputFormField(
              id: 'refund_$index',
              validator: (v) => validator(v),
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: onAmountChanged,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Text(
              formatAmount(price).toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
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
