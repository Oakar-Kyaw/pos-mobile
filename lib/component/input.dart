import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Widget input(
  BuildContext context, {
  required String label,
  required TextEditingController controller,
  required Color labelColor,
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: ShadInputFormField(
      controller: controller,
      label: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold, color: labelColor),
      ),
      maxLines: maxLines,
    ),
  );
}
