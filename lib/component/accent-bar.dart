import 'package:flutter/material.dart';
import 'package:pos/utils/app-theme.dart';

class AccentBar extends StatelessWidget {
  const AccentBar({required this.hasDebt});

  final bool hasDebt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: hasDebt
              ? [Colors.red, Colors.red.withOpacity(0.4)]
              : [kPrimary, kPrimary.withOpacity(0.4)],
        ),
      ),
    );
  }
}
