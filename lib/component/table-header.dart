import 'package:flutter/material.dart';
import 'package:pos/utils/font-size.dart';

Widget buildTableHeader(
  String text,
  BuildContext context,
  Color textColor, {
  bool alignRight = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: FontSizeConfig.body(context),
          color: textColor,
          letterSpacing: 0.2,
        ),
      ),
    ),
  );
}
