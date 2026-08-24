import 'package:flutter/material.dart';
import 'package:pos/utils/responsive.dart';

class FontSizeConfig {
  static double title(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return 14.0;
    } else if (Responsive.isTablet(context)) {
      return 18.0;
    } else {
      return 20.0;
    }
  }

  static double body(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return 12.5;
    } else if (Responsive.isTablet(context)) {
      return 17;
    } else {
      return 21;
    }
  }

  static double iconSize(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return 20;
    } else if (Responsive.isTablet(context)) {
      return 24;
    } else {
      return 28;
    }
  }
}
