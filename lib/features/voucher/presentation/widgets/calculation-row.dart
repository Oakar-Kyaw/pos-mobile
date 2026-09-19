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
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 3,
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
      ),
      const SizedBox(width: 8),
      Flexible(
        flex: 2,
        child: Text(
          value.toStringAsFixed(2),
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          maxLines: 5,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: highlight
                ? FontSizeConfig.title(context)
                : FontSizeConfig.body(context),
            color: valueColor,
          ),
        ),
      ),
    ],
  );
}
