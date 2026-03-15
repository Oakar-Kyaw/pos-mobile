import 'package:pos/localization/attendance-local.dart';
import 'package:pos/localization/category-local.dart';
import 'package:pos/localization/company-local.dart';
import 'package:pos/localization/debt-local.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/employee-local.dart';
import 'package:pos/localization/error-local.dart';
import 'package:pos/localization/general-expense-local.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/localization/home-local.dart';
import 'package:pos/localization/hr-rule-local.dart';
import 'package:pos/localization/income-local.dart';
import 'package:pos/localization/inventory-management-local.dart';
import 'package:pos/localization/login-local.dart';
import 'package:pos/localization/payment-data-local.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/localization/payroll-local.dart';
import 'package:pos/localization/product-local.dart';
import 'package:pos/localization/refund-local.dart';
import 'package:pos/localization/repay-local.dart';
import 'package:pos/localization/sale-report-local.dart';
import 'package:pos/localization/voucher-local.dart';

mixin AppLocale {
  static const Map<String, dynamic> EN = {
    ...HomeScreenLocale.EN,
    ...DrawerScreenLocale.EN,
    ...CategoryScreenLocale.EN,
    ...CompanyRegisterScreenLocal.EN,
    ...LoginScreenLocale.EN,
    ...ProductScreenLocale.EN,
    ...ErrorScreenLocale.EN,
    ...VoucherScreenLocale.EN,
    ...PaymentScreenLocale.EN,
    ...SaleReportLocale.EN,
    ...IncomeScreenLocale.EN,
    ...GeneralExpenseLocale.EN,
    ...PaymentDataLocale.EN,
    ...RefundLocale.EN,
    ...DebtLocaleScreenLocale.EN,
    ...RepayLocaleScreen.EN,
    ...InventoryManagementLocale.EN,
    ...EmployeeLocaleScreenLocale.EN,
    ...AttendanceLocaleScreenLocale.EN,
    ...PayrollLocaleScreenLocale.EN,
    ...HrRuleLocaleScreen.EN,
    ...GeneralScreenLocale.EN,
  };

  static const Map<String, dynamic> MM = {
    ...HomeScreenLocale.MM,
    ...DrawerScreenLocale.MM,
    ...CategoryScreenLocale.MM,
    ...CompanyRegisterScreenLocal.MM,
    ...LoginScreenLocale.MM,
    ...ProductScreenLocale.MM,
    ...ErrorScreenLocale.MM,
    ...VoucherScreenLocale.MM,
    ...PaymentScreenLocale.MM,
    ...SaleReportLocale.MM,
    ...IncomeScreenLocale.MM,
    ...GeneralExpenseLocale.MM,
    ...PaymentDataLocale.MM,
    ...RefundLocale.MM,
    ...DebtLocaleScreenLocale.MM,
    ...RepayLocaleScreen.MM,
    ...InventoryManagementLocale.MM,
    ...EmployeeLocaleScreenLocale.MM,
    ...AttendanceLocaleScreenLocale.MM,
    ...PayrollLocaleScreenLocale.MM,
    ...HrRuleLocaleScreen.MM,
    ...GeneralScreenLocale.MM,
  };
}
