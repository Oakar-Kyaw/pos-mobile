import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Widget rowPayment(
  String id,
  String label,
  double value,
  Color textColor,
  Color valueColor, {
  bool highlight = false,
  required Function(String id, String value) handleChangeAmount,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        flex: 2,
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
      ),

      const SizedBox(width: 8),

      Expanded(
        flex: 3,
        child: ShadInput(
          initialValue: value == 0 ? '' : value.toStringAsFixed(0),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.end,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          style: TextStyle(
            color: valueColor,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
          onChanged: (val) => handleChangeAmount(id, val),
        ),
      ),
    ],
  );
}
