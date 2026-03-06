import 'package:flutter/material.dart';

class LeftAccentBar extends StatelessWidget {
  const LeftAccentBar({super.key, required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      child: Container(
        width: 4,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [accent, accent.withOpacity(0.3)],
          ),
        ),
      ),
    );
  }
}
