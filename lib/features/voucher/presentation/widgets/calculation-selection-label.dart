// ── Section label ──────────────────────────────
import 'package:flutter/widgets.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';

Widget sectionLabel(BuildContext context, String title, Color textColor) {
  return Row(
    children: [
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kPrimary, kSecondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        title,
        style: TextStyle(
          fontSize: FontSizeConfig.body1(context),
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.2,
        ),
      ),
    ],
  );
}
