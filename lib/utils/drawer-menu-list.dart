import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/localization/customer-local.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/supplier-local.dart';
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

// A group of menu items under an optional section header.
// `title == null` means the group renders with no header (e.g. the
// first "Home" item, or the trailing "Upgrade" item).
class MenuSection {
  final String? title;
  final List<MenuItem> items;

  const MenuSection({this.title, required this.items});
}

List<MenuSection> menuListByAdmin(BuildContext context) => [
  MenuSection(
    items: [
      MenuItem(
        icon: LucideIcons.house,
        label: DrawerScreenLocale.drawerHome.getString(context),
        route: AppRoute.home,
      ),
      MenuItem(
        icon: LucideIcons.bell,
        label: DrawerScreenLocale.drawerNotification.getString(context),
        route: AppRoute.notification,
      ),
    ],
  ),

  // ───────── PRODUCT ─────────
  MenuSection(
    title: DrawerScreenLocale.drawerSectionProduct.getString(context),
    items: [
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
        label: DrawerScreenLocale.drawerViewProducts.getString(context),
        route: AppRoute.productList,
      ),
      MenuItem(
        icon: LucideIcons.packagePlus,
        label: DrawerScreenLocale.drawerAddProduct.getString(context),
        route: AppRoute.product,
      ),
    ],
  ),

  // ───────── SALE MANAGEMENT ─────────
  MenuSection(
    title: DrawerScreenLocale.drawerSectionSaleManagement.getString(context),
    items: [
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
    ],
  ),

  // ───────── FINANCE ─────────
  MenuSection(
    title: DrawerScreenLocale.drawerSectionFinance.getString(context),
    items: [
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
    ],
  ),

  // ───────── PROFIT ─────────
  MenuSection(
    title: 'Profit',
    items: [
      MenuItem(
        icon: LucideIcons.chartNoAxesCombined,
        label: DrawerScreenLocale.drawerProfit.getString(context),
        route: AppRoute.profitAndLoss,
      ),
    ],
  ),

  // ───────── HR / EMPLOYEE MANAGEMENT ─────────
  MenuSection(
    title: DrawerScreenLocale.drawerSectionEmployeeManagement.getString(
      context,
    ),
    items: [
      MenuItem(
        icon: LucideIcons.users,
        label: DrawerScreenLocale.drawerEmployee.getString(context),
        route: AppRoute.employee,
      ),
      // Attendance / Leave / Payroll / HrRule stay commented out,
      // same as the original list.
      // MenuItem(
      //   icon: LucideIcons.calendarCheck,
      //   label: DrawerScreenLocale.drawerAttendance.getString(context),
      //   route: AppRoute.attendance,
      // ),
      // MenuItem(
      //   icon: Icons.event_busy,
      //   label: DrawerScreenLocale.drawerLeave.getString(context),
      //   route: AppRoute.leave,
      // ),
      // MenuItem(
      //   icon: LucideIcons.banknote,
      //   label: DrawerScreenLocale.drawerEmployeeSalary.getString(context),
      //   route: AppRoute.payroll,
      // ),
      // MenuItem(
      //   icon: LucideIcons.clipboardCheck,
      //   label: DrawerScreenLocale.drawerHrRule.getString(context),
      //   route: AppRoute.hrRule,
      // ),
    ],
  ),

  // ───────── INVENTORY CONTROL ─────────
  MenuSection(
    title: DrawerScreenLocale.drawerSectionInventoryControl.getString(context),
    items: [
      MenuItem(
        icon: LucideIcons.shoppingCart,
        label: DrawerScreenLocale.drawerPurchaseItems.getString(context),
        route: AppRoute.purchaseHistory,
      ),
      MenuItem(
        icon: LucideIcons.triangle,
        label: DrawerScreenLocale.drawerExpireItems.getString(context),
        route: AppRoute.expireItem,
      ),
      MenuItem(
        icon: LucideIcons.packageX,
        label: DrawerScreenLocale.drawerLowStock.getString(context),
        route: AppRoute.lowStock,
      ),
      MenuItem(
        icon: LucideIcons.clipboardPlus,
        label: DrawerScreenLocale.drawerRequestItems.getString(context),
        route: AppRoute.requestItem,
      ),
      MenuItem(
        icon: LucideIcons.truck,
        label: SupplierLocale.supplierManagementTitle.getString(context),
        route: AppRoute.supplier,
      ),
      MenuItem(
        icon: LucideIcons.users,
        label: CustomerLocale.customerManagementTitle.getString(context),
        route: AppRoute.customer,
      ),
    ],
  ),

  MenuSection(
    items: [
      MenuItem(
        icon: LucideIcons.rocket,
        label: DrawerScreenLocale.drawerUpgrade.getString(context),
        route: AppRoute.accountUpgrade,
      ),
    ],
  ),
];

List<MenuSection> menuListBySale(BuildContext context) => [
  MenuSection(
    items: [
      MenuItem(
        icon: LucideIcons.bell,
        label: DrawerScreenLocale.drawerNotification.getString(context),
        route: AppRoute.notification,
      ),
    ],
  ),

  // ───────── SALE MANAGEMENT ─────────
  MenuSection(
    title: DrawerScreenLocale.drawerSectionSaleManagement.getString(context),
    items: [
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
        icon: LucideIcons.packageX,
        label: DrawerScreenLocale.drawerLowStock.getString(context),
        route: AppRoute.lowStock,
      ),
    ],
  ),

  // ───────── EMPLOYEE MANAGEMENT ─────────
  MenuSection(
    title: DrawerScreenLocale.drawerSectionEmployeeManagement.getString(
      context,
    ),
    items: [
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
    ],
  ),
];

List<MenuSection> menuListByManager(BuildContext context) => [
  MenuSection(
    items: [
      MenuItem(
        icon: LucideIcons.bell,
        label: DrawerScreenLocale.drawerNotification.getString(context),
        route: AppRoute.notification,
      ),
    ],
  ),

  // ───────── SALE MANAGEMENT ─────────
  MenuSection(
    title: DrawerScreenLocale.drawerSectionSaleManagement.getString(context),
    items: [
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
    ],
  ),

  // ───────── FINANCE ─────────
  MenuSection(
    title: DrawerScreenLocale.drawerSectionFinance.getString(context),
    items: [
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
    ],
  ),

  // ───────── PROFIT ─────────
  // NOTE: kept the original route (AppRoute.home) exactly as given —
  // this looked like it might be a placeholder/unfinished route in the
  // source file. Flag this to Oakar; probably should be
  // AppRoute.profitAndLoss like in menuListByAdmin.
  MenuSection(
    title: DrawerScreenLocale.drawerSectionProfit.getString(context),
    items: [
      MenuItem(
        icon: LucideIcons.coins,
        label: DrawerScreenLocale.drawerProfit.getString(context),
        route: AppRoute.home,
      ),
    ],
  ),

  // ───────── EMPLOYEE MANAGEMENT ─────────
  MenuSection(
    title: DrawerScreenLocale.drawerSectionEmployeeManagement.getString(
      context,
    ),
    items: [
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
    ],
  ),

  // ───────── INVENTORY CONTROL ─────────
  MenuSection(
    title: DrawerScreenLocale.drawerSectionInventoryControl.getString(context),
    items: [
      MenuItem(
        icon: LucideIcons.triangle,
        label: DrawerScreenLocale.drawerExpireItems.getString(context),
        route: AppRoute.expireItem,
      ),
      MenuItem(
        icon: LucideIcons.packageX,
        label: DrawerScreenLocale.drawerLowStock.getString(context),
        route: AppRoute.lowStock,
      ),
      MenuItem(
        icon: LucideIcons.clipboardPlus,
        label: DrawerScreenLocale.drawerRequestItems.getString(context),
        route: AppRoute.requestItem,
      ),
      MenuItem(
        icon: LucideIcons.truck,
        label: SupplierLocale.supplierManagementTitle.getString(context),
        route: AppRoute.supplier,
      ),
    ],
  ),

  // NOTE: both of these also point at AppRoute.home in the original —
  // flagging in case that's unfinished too.
  MenuSection(
    items: [
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
    ],
  ),
];
