import 'package:flutter/material.dart';
import 'package:pos/utils/app-theme.dart';

class LeftGreenBar extends StatelessWidget {
  const LeftGreenBar({super.key});

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
          colors: [kGreen, kGreen.withOpacity(0.4)],
        ),
      ),
    );
  }
}
