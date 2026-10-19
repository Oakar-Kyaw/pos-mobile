import 'package:flutter/material.dart';
import 'package:pos/utils/responsive.dart';

class FontSizeConfig {
  // Device အလိုက် တန်ဖိုးရွေးပေးတဲ့ helper
  static double _pick(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (Responsive.isMobile(context)) return mobile;
    if (Responsive.isTablet(context)) return tablet;
    return desktop;
  }

  // ---------- Title (1 အကြီးဆုံး → 5 အသေးဆုံး) ----------
  static double title1(BuildContext context) =>
      _pick(context, mobile: 16.0, tablet: 18.0, desktop: 22.0);

  static double title2(BuildContext context) =>
      _pick(context, mobile: 14.0, tablet: 15.0, desktop: 18.0);

  static double title3(BuildContext context) =>
      _pick(context, mobile: 13.0, tablet: 14.0, desktop: 16.0);

  static double title4(BuildContext context) =>
      _pick(context, mobile: 12.0, tablet: 13.0, desktop: 15.0);

  static double title5(BuildContext context) =>
      _pick(context, mobile: 11.0, tablet: 12.0, desktop: 14.0);

  /// အရင်ကုဒ်တွေ မပျက်အောင် ထားထားတာ
  static double title(BuildContext context) => title2(context);

  // ---------- Body (1 အကြီးဆုံး → 5 အသေးဆုံး) ----------
  static double body1(BuildContext context) =>
      _pick(context, mobile: 12.5, tablet: 13.5, desktop: 16.5);

  static double body2(BuildContext context) =>
      _pick(context, mobile: 11.0, tablet: 12.0, desktop: 14.0);

  static double body3(BuildContext context) =>
      _pick(context, mobile: 10.0, tablet: 11.0, desktop: 13.0);

  static double body4(BuildContext context) =>
      _pick(context, mobile: 9.5, tablet: 10.0, desktop: 12.0);

  static double body5(BuildContext context) =>
      _pick(context, mobile: 9.0, tablet: 9.5, desktop: 11.0);

  /// အရင်ကုဒ်တွေ မပျက်အောင် ထားထားတာ
  static double body(BuildContext context) => body1(context);

  // ---------- Icon (1 အကြီးဆုံး → 5 အသေးဆုံး) ----------
  static double iconSize1(BuildContext context) =>
      _pick(context, mobile: 20.0, tablet: 22.0, desktop: 24.0);

  static double iconSize2(BuildContext context) =>
      _pick(context, mobile: 16.0, tablet: 18.0, desktop: 20.0);

  static double iconSize3(BuildContext context) =>
      _pick(context, mobile: 14.0, tablet: 16.0, desktop: 18.0);

  static double iconSize4(BuildContext context) =>
      _pick(context, mobile: 12.0, tablet: 14.0, desktop: 16.0);

  static double iconSize5(BuildContext context) =>
      _pick(context, mobile: 10.0, tablet: 12.0, desktop: 14.0);

  /// အရင်ကုဒ်တွေ မပျက်အောင် ထားထားတာ
  static double iconSize(BuildContext context) => iconSize1(context);
}
