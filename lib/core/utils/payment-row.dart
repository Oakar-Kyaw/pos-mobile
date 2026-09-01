import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Reusable widget — payment row တစ်ခုစီအတွက်
/// (account name + amount input + remove button)
class PaymentRow extends ConsumerWidget {
  const PaymentRow({
    super.key,
    required this.index,
    required this.accountName,
    required this.controller,
    required this.onAmountChanged,
    required this.onRemove,
    required this.validator,
  });

  final int index;

  final String accountName;

  final TextEditingController controller;

  final ValueChanged<String> onAmountChanged;

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
            flex: 3,
            child: Text(accountName, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 9,
            child: ShadInputFormField(
              id: 'payment_$index',
              validator: (v) => validator(v),
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: onAmountChanged,
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
