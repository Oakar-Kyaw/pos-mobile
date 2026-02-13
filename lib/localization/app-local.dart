import 'package:pos/localization/category-local.dart';
import 'package:pos/localization/company-local.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/error-local.dart';
import 'package:pos/localization/home-local.dart';
import 'package:pos/localization/login-local.dart';
import 'package:pos/localization/product-local.dart';

mixin AppLocale {
  static const Map<String, dynamic> EN = {
    ...HomeScreenLocale.EN,
    ...DrawerScreenLocale.EN,
    ...CategoryScreenLocale.EN,
    ...CompanyRegisterScreenLocal.EN,
    ...LoginScreenLocale.EN,
    ...ProductScreenLocale.EN,
    ...ErrorScreenLocale.EN,
  };

  static const Map<String, dynamic> MM = {
    ...HomeScreenLocale.MM,
    ...DrawerScreenLocale.MM,
    ...CategoryScreenLocale.MM,
    ...CompanyRegisterScreenLocal.MM,
    ...LoginScreenLocale.MM,
    ...ProductScreenLocale.MM,
    ...ErrorScreenLocale.MM,
  };
}
