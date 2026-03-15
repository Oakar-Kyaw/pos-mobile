import 'package:flutter/material.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class GradientSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double width;
  final BoxDecoration decoration;

  GradientSubmitButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.width,
    BoxDecoration? decoration,
  }) : decoration =
           decoration ??
           BoxDecoration(
             gradient: const LinearGradient(
               colors: [kPrimary, kSecondary],
               begin: Alignment.centerLeft,
               end: Alignment.centerRight,
             ),
             borderRadius: BorderRadius.circular(8),
           );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: decoration,
        child: ShadButton(
          backgroundColor: Colors.transparent,
          onPressed: onPressed,
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
