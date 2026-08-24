import 'package:flutter/material.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';

class customButton extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool gradient;
  final double minWidth;
  final double horizontal;
  final double vertical;
  final VoidCallback onTap;

  const customButton({
    required this.label,
    required this.isDark,
    required this.gradient,
    required this.onTap,
    this.minWidth = 120,
    this.horizontal = 22,
    this.vertical = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth),
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: gradient
              ? const LinearGradient(
                  colors: [kPrimary, kSecondary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: gradient
              ? null
              : (isDark ? Colors.white.withOpacity(0.12) : Colors.white),
          borderRadius: BorderRadius.circular(22),
          boxShadow: gradient
              ? [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: FontSizeConfig.body(context),
            color: gradient
                ? Colors.white
                : (isDark ? Colors.white : kTextLight),
          ),
        ),
      ),
    );
  }
}
