import 'package:pos/localization/account-upgrade.dart';
import 'package:pos/localization/plan_feature_locale.dart';

final planLocaleMap = {
  'MONTHLY': AccountUpgradeScreenLocale.upgradeMonthly,
  'SIX_MONTHS': AccountUpgradeScreenLocale.upgradeSixMonths,
  'YEARLY': AccountUpgradeScreenLocale.upgradeYearly,
};

final planFeatureKeys = {
  "bank_account": PlanFeatureLocaleScreen.bankAccount,
  "category_management": PlanFeatureLocaleScreen.categoryManagement,
  "product_management": PlanFeatureLocaleScreen.productManagement,
  "voucher_management": PlanFeatureLocaleScreen.voucherManagement,
  "income_view": PlanFeatureLocaleScreen.incomeView,
  "sale_report": PlanFeatureLocaleScreen.saleReport,
  "expense_management": PlanFeatureLocaleScreen.expenseManagement,
  "refund_management": PlanFeatureLocaleScreen.refundManagement,
  "debt_management": PlanFeatureLocaleScreen.debtManagement,
  "repay_management": PlanFeatureLocaleScreen.repayManagement,
  "profit_and_loss": PlanFeatureLocaleScreen.profitAndLoss,
  "employee_management": PlanFeatureLocaleScreen.employeeManagement,
  "daily_sale": PlanFeatureLocaleScreen.dailySale,
  "daily_sale_report": PlanFeatureLocaleScreen.dailySaleReport,
  "request_item": PlanFeatureLocaleScreen.requestItem,
  "damage_item": PlanFeatureLocaleScreen.damageItem,
  "theme": PlanFeatureLocaleScreen.theme,
  "language": PlanFeatureLocaleScreen.language,
};
