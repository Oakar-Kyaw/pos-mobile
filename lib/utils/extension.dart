import 'package:flutter/material.dart';

extension AppTextStyle on BuildContext {
  TextStyle? get titleStyle => Theme.of(this).textTheme.titleLarge;
  TextStyle? get bodyStyle => Theme.of(this).textTheme.bodyMedium;
}
