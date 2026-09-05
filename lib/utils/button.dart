import 'package:flutter/material.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class GradientSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double width;
  final BoxDecoration decoration;
  double circularNo;
  bool isSubmitting;

  GradientSubmitButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.width,
    BoxDecoration? decoration,
    this.circularNo = 2,
    this.isSubmitting = false,
  }) : decoration =
           decoration ??
           BoxDecoration(
             gradient: const LinearGradient(
               colors: [kPrimary, kSecondary],
               begin: Alignment.centerLeft,
               end: Alignment.centerRight,
             ),
             borderRadius: BorderRadius.circular(circularNo),
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
          child: isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: LoadingWidget(color: kBgLight),
                )
              : Text(text, style: const TextStyle(color: kBgLight)),
        ),
      ),
    );
  }
}
