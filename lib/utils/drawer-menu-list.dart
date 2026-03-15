import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MenuItem {
  final IconData icon;
  final String label;
  final String route;
  const MenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

List<MenuItem> menuListByAdmin(BuildContext context) => [
  MenuItem(
    icon: LucideIcons.house,
    label: DrawerScreenLocale.drawerHome.getString(context),
    route: AppRoute.home,
  ),
  MenuItem(
    icon: LucideIcons.creditCard,
    label: DrawerScreenLocale.drawerBankAccount.getString(context),
    route: AppRoute.account,
  ),
  MenuItem(
    icon: LucideIcons.tag,
    label: DrawerScreenLocale.drawerCategory.getString(context),
    route: AppRoute.category,
  ),
  MenuItem(
    icon: LucideIcons.packageOpen,
    label: DrawerScreenLocale.drawerProduct.getString(context),
    route: AppRoute.product,
  ),

  // ───────── SALES ─────────
  MenuItem(
    icon: LucideIcons.ticket,
    label: DrawerScreenLocale.drawerVoucher.getString(context),
    route: AppRoute.vouchers,
  ),
  MenuItem(
    icon: LucideIcons.trendingUp,
    label: DrawerScreenLocale.drawerIncome.getString(context),
    route: AppRoute.income,
  ),
  MenuItem(
    icon: LucideIcons.clipboardList,
    label: DrawerScreenLocale.drawerSaleReport.getString(context),
    route: AppRoute.saleReports,
  ),

  // ───────── FINANCE ─────────
  MenuItem(
    icon: LucideIcons.receipt,
    label: DrawerScreenLocale.drawerExpense.getString(context),
    route: AppRoute.generalExpense,
  ),
  MenuItem(
    icon: LucideIcons.rotateCcw,
    label: DrawerScreenLocale.drawerRefund.getString(context),
    route: AppRoute.refund,
  ),
  MenuItem(
    icon: LucideIcons.wallet,
    label: DrawerScreenLocale.drawerDebt.getString(context),
    route: AppRoute.debt,
  ),
  MenuItem(
    icon: LucideIcons.handCoins,
    label: DrawerScreenLocale.drawerRepay.getString(context),
    route: AppRoute.repay,
  ),
  MenuItem(
    icon: LucideIcons.coins,
    label: DrawerScreenLocale.drawerProfit.getString(context),
    route: AppRoute.home,
  ),

  // ───────── HR ─────────
  MenuItem(
    icon: LucideIcons.users,
    label: DrawerScreenLocale.drawerEmployee.getString(context),
    route: AppRoute.employee,
  ),
  MenuItem(
    icon: LucideIcons.calendarCheck,
    label: DrawerScreenLocale.drawerAttendance.getString(context),
    route: AppRoute.attendance,
  ),
  MenuItem(
    icon: LucideIcons.banknote,
    label: DrawerScreenLocale.drawerEmployeeSalary.getString(context),
    route: AppRoute.payroll,
  ),
  MenuItem(
    icon: LucideIcons.clipboardCheck,
    label: DrawerScreenLocale.drawerHrRule.getString(context),
    route: AppRoute.hrRule,
  ),

  // ───────── INVENTORY CONTROL ─────────
  MenuItem(
    icon: LucideIcons.triangle,
    label: DrawerScreenLocale.drawerExpireItems.getString(context),
    route: AppRoute.expireItem,
  ),
  MenuItem(
    icon: LucideIcons.clipboardPlus,
    label: DrawerScreenLocale.drawerRequestItems.getString(context),
    route: AppRoute.requestItem,
  ),

  MenuItem(
    icon: LucideIcons.rocket,
    label: DrawerScreenLocale.drawerUpgrade.getString(context),
    route: AppRoute.home,
  ),

  MenuItem(
    icon: LucideIcons.rocket,
    label: DrawerScreenLocale.drawerUpgradeSuggestion.getString(context),
    route: AppRoute.home,
  ),
];

List<MenuItem> menuListBySale(BuildContext context) => [
  // ───────── SALES ─────────
  MenuItem(
    icon: LucideIcons.ticket,
    label: DrawerScreenLocale.drawerVoucher.getString(context),
    route: AppRoute.vouchers,
  ),
  MenuItem(
    icon: LucideIcons.rotateCcw,
    label: DrawerScreenLocale.drawerRefund.getString(context),
    route: AppRoute.refund,
  ),
  MenuItem(
    icon: LucideIcons.wallet,
    label: DrawerScreenLocale.drawerDebt.getString(context),
    route: AppRoute.debt,
  ),
  MenuItem(
    icon: LucideIcons.clipboardList,
    label: DrawerScreenLocale.drawerSaleReport.getString(context),
    route: AppRoute.saleReports,
  ),
  MenuItem(
    icon: LucideIcons.calendarCheck,
    label: DrawerScreenLocale.drawerAttendance.getString(context),
    route: AppRoute.attendance,
  ),
  MenuItem(
    icon: LucideIcons.banknote,
    label: DrawerScreenLocale.drawerEmployeeSalary.getString(context),
    route: AppRoute.payroll,
  ),
];

List<MenuItem> menuListByManager(BuildContext context) => [
  // ───────── SALES ─────────
  MenuItem(
    icon: LucideIcons.ticket,
    label: DrawerScreenLocale.drawerVoucher.getString(context),
    route: AppRoute.vouchers,
  ),
  MenuItem(
    icon: LucideIcons.trendingUp,
    label: DrawerScreenLocale.drawerIncome.getString(context),
    route: AppRoute.income,
  ),
  MenuItem(
    icon: LucideIcons.clipboardList,
    label: DrawerScreenLocale.drawerSaleReport.getString(context),
    route: AppRoute.saleReports,
  ),

  // ───────── FINANCE ─────────
  MenuItem(
    icon: LucideIcons.receipt,
    label: DrawerScreenLocale.drawerExpense.getString(context),
    route: AppRoute.generalExpense,
  ),
  MenuItem(
    icon: LucideIcons.rotateCcw,
    label: DrawerScreenLocale.drawerRefund.getString(context),
    route: AppRoute.refund,
  ),
  MenuItem(
    icon: LucideIcons.wallet,
    label: DrawerScreenLocale.drawerDebt.getString(context),
    route: AppRoute.debt,
  ),
  MenuItem(
    icon: LucideIcons.handCoins,
    label: DrawerScreenLocale.drawerRepay.getString(context),
    route: AppRoute.repay,
  ),
  MenuItem(
    icon: LucideIcons.coins,
    label: DrawerScreenLocale.drawerProfit.getString(context),
    route: AppRoute.home,
  ),

  // ───────── HR ─────────
  MenuItem(
    icon: LucideIcons.users,
    label: DrawerScreenLocale.drawerEmployee.getString(context),
    route: AppRoute.employee,
  ),
  MenuItem(
    icon: LucideIcons.calendarCheck,
    label: DrawerScreenLocale.drawerAttendance.getString(context),
    route: AppRoute.attendance,
  ),
  MenuItem(
    icon: LucideIcons.banknote,
    label: DrawerScreenLocale.drawerEmployeeSalary.getString(context),
    route: AppRoute.payroll,
  ),
  MenuItem(
    icon: LucideIcons.clipboardCheck,
    label: DrawerScreenLocale.drawerHrRule.getString(context),
    route: AppRoute.hrRule,
  ),

  // ───────── INVENTORY CONTROL ─────────
  MenuItem(
    icon: LucideIcons.triangle,
    label: DrawerScreenLocale.drawerExpireItems.getString(context),
    route: AppRoute.expireItem,
  ),
  MenuItem(
    icon: LucideIcons.clipboardPlus,
    label: DrawerScreenLocale.drawerRequestItems.getString(context),
    route: AppRoute.requestItem,
  ),

  MenuItem(
    icon: LucideIcons.rocket,
    label: DrawerScreenLocale.drawerUpgrade.getString(context),
    route: AppRoute.home,
  ),

  MenuItem(
    icon: LucideIcons.rocket,
    label: DrawerScreenLocale.drawerUpgradeSuggestion.getString(context),
    route: AppRoute.home,
  ),
];
