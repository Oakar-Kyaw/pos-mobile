import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Widget rowPayment(
  String id,
  String label,
  double value,
  Color textColor,
  Color valueColor, {
  bool highlight = false,
  required Function handleChangeAmount,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      SizedBox(
        width: 120,
        child: Text(
          label,
          maxLines: 2,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
      ),
      SizedBox(
        width: 100,
        child: ShadInput(
          initialValue: value.toString(),
          onChanged: (value) => handleChangeAmount(id, value),
        ),
      ),
    ],
  );
}
