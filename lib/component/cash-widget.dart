import 'package:flutter/material.dart';

//─────────────────────────────────────────────
// Legacy CashWidget (kept for compatibility)
// ─────────────────────────────────────────────
class CashWidget extends StatelessWidget {
  final String title;
  final String amount;

  const CashWidget({super.key, required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
