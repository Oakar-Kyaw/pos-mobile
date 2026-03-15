import 'package:flutter/material.dart';
import 'package:pos/utils/app-theme.dart';

Widget buildCardCell(
  String text,
  Color textColor, {
  bool alignRight = false,
  bool highlight = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
    child: Align(
      alignment: !alignRight ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 4,
        style: TextStyle(
          color: highlight ? kPrimary : textColor,
          fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    ),
  );
}
