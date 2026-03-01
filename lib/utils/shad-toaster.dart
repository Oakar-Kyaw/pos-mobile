import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void ShowToast(
  BuildContext context, {
  Widget? action,
  Widget? description,
  Color? borderColor,
}) {
  ShadToaster.of(context).show(
    ShadToast(
      alignment: Alignment.topCenter,
      border: ShadBorder.all(
        width: 1,
        color: borderColor ?? Colors.greenAccent,
      ),
      action:
          action ?? Icon(LucideIcons.circleCheck, color: Colors.greenAccent),
      description: description,
    ),
  );
}
