import 'package:flutter/material.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';

Widget buildTableCell(
  String text,
  Color textColor, {
  bool alignRight = false,
  bool highlight = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
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
