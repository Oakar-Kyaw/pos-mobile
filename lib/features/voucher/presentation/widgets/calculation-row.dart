import 'package:flutter/widgets.dart';
import 'package:pos/utils/font-size.dart';

Widget row(
  BuildContext context,
  String label,
  double value,
  Color textColor,
  Color valueColor, {
  bool highlight = false,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      SizedBox(
        width: 200,
        child: Text(
          label,
          maxLines: 2,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
      ),
      Text(
        value.toStringAsFixed(2),
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: highlight
              ? FontSizeConfig.title(context)
              : FontSizeConfig.body(context),
          color: valueColor,
        ),
      ),
    ],
  );
}
