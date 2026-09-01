import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/utils/app-theme.dart';

enum CustomActionType { edit, cancel, update }

class CustomActionButton extends StatelessWidget {
  const CustomActionButton({
    super.key,
    required this.type,
    required this.onPressed,
  });

  final CustomActionType type;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(context);

    return IconButton(
      tooltip: config.tooltip,
      icon: Icon(config.icon, color: Colors.white, size: 18),
      style: IconButton.styleFrom(
        backgroundColor: config.backgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(36, 36),
        maximumSize: const Size(36, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
    );
  }

  CustomActionConfig _getConfig(BuildContext context) {
    switch (type) {
      case CustomActionType.edit:
        return CustomActionConfig(
          icon: Icons.edit_outlined,
          backgroundColor: Colors.green,
          tooltip: GeneralScreenLocale.edit.getString(context),
        );

      case CustomActionType.cancel:
        return CustomActionConfig(
          icon: Icons.close,
          backgroundColor: Colors.red,
          tooltip: GeneralScreenLocale.cancel.getString(context),
        );

      case CustomActionType.update:
        return CustomActionConfig(
          icon: Icons.check,
          backgroundColor: kPrimary,
          tooltip: GeneralScreenLocale.save.getString(context),
        );
    }
  }
}

class CustomActionConfig {
  const CustomActionConfig({
    required this.icon,
    required this.backgroundColor,
    required this.tooltip,
  });

  final IconData icon;
  final Color backgroundColor;
  final String tooltip;
}
