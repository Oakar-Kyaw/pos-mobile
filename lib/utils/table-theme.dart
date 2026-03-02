import 'package:flutter/material.dart';

class TableThemeConfiguration {
  final bool isDark;
  final Color surfaceColor;
  final Color kPrimary;
  final Color kSecondary;
  final Color dividerColor;
  TableThemeConfiguration({
    required this.isDark,
    required this.surfaceColor,
    required this.kPrimary,
    required this.kSecondary,
    required this.dividerColor,
  });

  BoxDecoration getTableContainerDecoration() {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? kPrimary.withOpacity(0.1)
              : Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  BoxDecoration getTableHeaderDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          kPrimary.withOpacity(isDark ? 0.25 : 0.08),
          kSecondary.withOpacity(isDark ? 0.15 : 0.04),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      border: Border(bottom: BorderSide(color: dividerColor, width: 1)),
    );
  }

  BoxDecoration getTableRowDecoration(bool isEven) {
    return BoxDecoration(
      color: isEven
          ? Colors.transparent
          : (isDark
                ? Colors.white.withOpacity(0.02)
                : Colors.black.withOpacity(0.01)),
      border: Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
    );
  }
}
