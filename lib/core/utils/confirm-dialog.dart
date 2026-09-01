import 'package:flutter/material.dart';

/// Generic confirmation dialog. Returns `true` if confirmed, `false`/`null` otherwise.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  required String confirmLabel,
  required String cancelLabel,
  Color confirmColor = Colors.red,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel, style: TextStyle(color: confirmColor)),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}
