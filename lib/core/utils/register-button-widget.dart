import 'package:flutter/material.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({
    super.key,
    required this.subColor,
    required this.onTap,
    required this.title,
    this.newToPos = false,
    this.newToPosString,
  });

  final Color subColor;
  final GestureTapCallback onTap;
  final String title;
  final bool newToPos;
  final String? newToPosString;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: subColor,
            fontSize: FontSizeConfig.body(context),
          ),
          children: [
            newToPos ? TextSpan(text: newToPosString) : TextSpan(),
            const TextSpan(text: "? "),
            TextSpan(
              text: title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: kPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
