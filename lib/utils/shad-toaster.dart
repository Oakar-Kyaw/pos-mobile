import 'package:flutter/material.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void ShowToast(
  BuildContext context, {
  Widget? action,
  Widget? description,
  Color? borderColor,
  bool isError = false,
}) {
  Color color = borderColor ?? (isError ? kRed : kGreenSecondary);
  final Widget defaultActionIcon = isError
      ? Icon(LucideIcons.x, color: Colors.redAccent)
      : Icon(LucideIcons.circleCheck, color: Colors.greenAccent);

  ShadToaster.of(context).show(
    ShadToast(
      alignment: Alignment.topCenter,
      border: ShadBorder.all(width: 1, color: color),
      action: defaultActionIcon,
      description: description,
    ),
  );
}
