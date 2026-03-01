// ─────────────────────────────────────────────
// Themed Divider
// ─────────────────────────────────────────────
import 'package:flutter/material.dart';

class ThemeDivider extends StatelessWidget {
  final Color color;
  const ThemeDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: color);
  }
}
