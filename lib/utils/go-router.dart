import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/features/account-upgrade/presentation/pages/account-upgrade.dart';
import 'package:pos/features/category/presentation/page/category.dart';
import 'package:pos/features/create-voucher/presentation/pages/create-voucher.dart';
import 'package:pos/features/customer/presentation/page/create-customer.dart';
import 'package:pos/features/customer/presentation/page/customer.dart';
import 'package:pos/features/expire-item/presentation/page/expire-item.dart';
import 'package:pos/features/general-expense/data/model/general-expense.dart';
import 'package:pos/features/general-expense/presentation/page/general-expense-create.dart';
import 'package:pos/features/general-expense/presentation/page/general-expense-edit.dart';
import 'package:pos/features/general-expense/presentation/page/general-expense.dart';
import 'package:pos/features/income/presentation/page/income.dart';
import 'package:pos/features/leave/presentation/pages/leave-create-page.dart';
import 'package:pos/features/leave/presentation/pages/leave-pages.dart';
import 'package:pos/features/payment-list/presentation/page/payment-list.dart';
import 'package:pos/features/printer/presentation/page/printer.page.dart';
import 'package:pos/features/product/presentation/page/product-bar-code-scan.dart';
import 'package:pos/features/product/presentation/page/product-list-page.dart';
import 'package:pos/features/purchase-history/data/model/purchase.dart';
import 'package:pos/features/purchase-history/presentation/page/create-purchase-item.dart';
import 'package:pos/features/purchase-history/presentation/page/purchase-detail.dart';
import 'package:pos/features/purchase-history/presentation/page/purchase-edit.dart';
import 'package:pos/features/purchase-history/presentation/page/purchase-history.dart';
import 'package:pos/features/refund/data/model/refund.dart';
import 'package:pos/features/refund/presentation/page/refund-create.dart';
import 'package:pos/features/refund/presentation/page/refund-edit.dart';
import 'package:pos/features/refund/presentation/page/refund.dart';
import 'package:pos/features/supplier/presentation/page/create-supplier.dart';
import 'package:pos/features/supplier/presentation/page/supplier.dart';
import 'package:pos/riverpod/login-check.dart';
import 'package:pos/src/attendance.dart';
import 'package:pos/src/attendance-create.dart';
import 'package:pos/src/company-profile.dart';
import 'package:pos/src/debt-voucher.dart';
import 'package:pos/src/employee.dart';
import 'package:pos/src/home.dart';
import 'package:pos/src/hr-rule.dart';
import 'package:pos/src/inventory-items.dart';
import 'package:pos/src/login.dart';
import 'package:pos/src/payroll-create.dart';
import 'package:pos/src/payroll-payslip.dart';
import 'package:pos/src/product.dart';
import 'package:pos/src/receipt.dart';
import 'package:pos/src/repay.dart';
import 'package:pos/src/request-item.dart';
import 'package:pos/src/payroll-salary.dart';
import 'package:pos/src/sale-report.dart';
import 'package:pos/src/setting.dart';
import 'package:pos/src/voucher.dart';
import 'package:pos/ui/employee-create.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

//go router can't listen to notifier that is why we should create this
final routeProvider = Provider<GoRouter>((ref) {
  // A. Create the "Radio" (The Bridge)
  // use ValueNotifier because GoRouter natively understands it.
  final authListener = ValueNotifier<bool>(false);
  // B. Sync the Radio (Riverpod -> Bridge)
  // Whenever checkLoginProvider changes, update the ValueNotifier.
  ref.listen(checkLoginProvider, (prev, next) {
    authListener.value = next;
  });
  // C. Clean up the radio when done
  ref.onDispose(() => authListener.dispose());

  return GoRouter(
    initialLocation: AppRoute.home,
    navigatorKey: rootNavigatorKey,
    // D. Give the Bouncer the Radio
    // Now, when authStateListener updates, the redirect logic re-runs.
    refreshListenable: authListener,
    redirect: (context, state) {
      // E. The Bouncer checks the ORIGINAL list (Riverpod)
      final isLogined = ref.read(checkLoginProvider);
      final isLoggingIn = state.matchedLocation == AppRoute.login;
      // 1. If NOT logged in and NOT trying to go to login page, force them to login.
      if (!isLogined) {
        return isLoggingIn ? null : AppRoute.login;
      }

      // 2. If ALREADY logged in and trying to go to login page, send them home.
      if (isLogined && isLoggingIn) {
        return AppRoute.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.home,
        name: AppRoute.home,
        builder: (context, state) => const MyHomePage(title: 'POS App'),
      ),
      GoRoute(
        path: AppRoute.settings,
        name: AppRoute.settings,
        builder: (context, state) => Setting(),
      ),
      GoRoute(
        path: AppRoute.profile,
        name: AppRoute.profile,
        builder: (context, state) => Setting(),
      ),
      GoRoute(
        path: AppRoute.category,
        name: AppRoute.category,
        builder: (context, state) => const CategoryPage(),
      ),
      GoRoute(
        path: AppRoute.companyProfile,
        name: AppRoute.companyProfile,
        builder: (context, state) => const CompanyProfilePage(),
      ),
      GoRoute(
        path: AppRoute.product,
        name: AppRoute.product,
        builder: (context, state) => const ProductPage(),
      ),
      GoRoute(
        path: AppRoute.createVoucher,
        name: AppRoute.createVoucher,
        builder: (context, state) => const CreateVoucherPage(),
      ),
      GoRoute(
        path: AppRoute.receipt,
        name: AppRoute.receipt,
        builder: (context, state) {
          int id = state.extra as int;
          return ReceiptPage(id: id);
        },
      ),
      GoRoute(
        path: AppRoute.vouchers,
        name: AppRoute.vouchers,
        builder: (context, state) => VoucherCardPage(),
      ),
      GoRoute(
        path: AppRoute.productBarcodeScan,
        name: AppRoute.productBarcodeScan,
        builder: (context, state) => ProductBarcodeScanPage(),
      ),
      GoRoute(
        path: AppRoute.productList,
        name: AppRoute.productList,
        builder: (context, state) => ProductListsPage(),
      ),
      // GoRoute(
      //   path: AppRoute.voucherCalculation,
      //   name: AppRoute.voucherCalculation,
      //   builder: (context, state) => VoucherCalculationPage(),
      // ),
      GoRoute(
        path: AppRoute.income,
        name: AppRoute.income,
        builder: (context, state) => IncomePage(),
      ),
      GoRoute(
        path: AppRoute.saleReports,
        name: AppRoute.saleReports,
        builder: (context, state) => SaleReportPage(),
      ),
      GoRoute(
        path: AppRoute.account,
        name: AppRoute.account,
        builder: (context, state) => PaymentDataPage(),
      ),
      GoRoute(
        path: AppRoute.generalExpense,
        name: AppRoute.generalExpense,
        builder: (context, state) => GeneralExpensePage(),
      ),
      GoRoute(
        path: AppRoute.generalExpenseCreate,
        name: AppRoute.generalExpenseCreate,
        builder: (context, state) => const GeneralExpenseCreatePage(),
      ),
      GoRoute(
        path: AppRoute.generalExpenseEdit,
        name: AppRoute.generalExpenseEdit,
        builder: (context, state) {
          GeneralExpense expense = state.extra as GeneralExpense;
          return GeneralExpenseEditPage(expense: expense);
        },
      ),
      GoRoute(
        path: AppRoute.refund,
        name: AppRoute.refund,
        builder: (context, state) => const RefundPage(),
      ),
      GoRoute(
        path: AppRoute.refundCreate,
        name: AppRoute.refundCreate,
        builder: (context, state) => const RefundCreatePage(),
      ),
      GoRoute(
        path: AppRoute.refundUpdate,
        name: AppRoute.refundUpdate,
        builder: (context, state) {
          final refund = state.extra as Refund;
          return RefundEditPage(refund: refund);
        },
      ),
      GoRoute(
        path: AppRoute.debt,
        name: AppRoute.debt,
        builder: (context, state) => const DebtVoucherPage(),
      ),
      GoRoute(
        path: AppRoute.repay,
        name: AppRoute.repay,
        builder: (context, state) => const RepaymentHistoryPage(),
      ),
      GoRoute(
        path: AppRoute.inventoryItem,
        name: AppRoute.inventoryItem,
        builder: (context, state) {
          //print("${state.extra} 🥸");
          String inventoryType = state.extra as String;
          return InventoryItemPage(type: inventoryType);
        },
      ),
      GoRoute(
        path: AppRoute.expireItem,
        name: AppRoute.expireItem,
        builder: (context, state) => ExpireItemsPage(),
      ),
      GoRoute(
        path: AppRoute.employee,
        name: AppRoute.employee,
        builder: (context, state) => EmployeePage(),
      ),
      GoRoute(
        path: AppRoute.employeeCreate,
        name: AppRoute.employeeCreate,
        builder: (context, state) => EmployeeCreatePage(),
      ),
      GoRoute(
        path: AppRoute.purchaseHistory,
        name: AppRoute.purchaseHistory,
        builder: (context, state) => PurchaseItemPage(),
      ),
      GoRoute(
        path: AppRoute.purchaseDetail,
        name: AppRoute.purchaseDetail,
        builder: (context, state) =>
            PurchaseDetailPage(purchase: state.extra as Purchase),
      ),
      GoRoute(
        path: AppRoute.purchaseEdit,
        name: AppRoute.purchaseEdit,
        builder: (context, state) =>
            PurchaseEditPage(purchase: state.extra as Purchase),
      ),
      GoRoute(
        path: AppRoute.purchaseCreate,
        name: AppRoute.purchaseCreate,
        builder: (context, state) => PurchaseCreatePage(),
      ),

      GoRoute(
        path: AppRoute.supplier,
        name: AppRoute.supplier,
        builder: (context, state) => SupplierPage(),
      ),

      GoRoute(
        path: AppRoute.customer,
        name: AppRoute.customer,
        builder: (context, state) => const CustomerPage(),
      ),

      GoRoute(
        path: AppRoute.customerCreate,
        name: AppRoute.customerCreate,
        builder: (context, state) => const CreateCustomerPage(),
      ),

      GoRoute(
        path: AppRoute.supplierCreate,
        name: AppRoute.supplierCreate,
        builder: (context, state) => const CreateSupplierPage(),
      ),

      GoRoute(
        path: AppRoute.requestItem,
        name: AppRoute.requestItem,
        builder: (context, state) => RequestItemPage(),
      ),
      GoRoute(
        path: AppRoute.attendance,
        name: AppRoute.attendance,
        builder: (context, state) => AttendancePage(),
      ),
      GoRoute(
        path: AppRoute.attendanceCreate,
        name: AppRoute.attendanceCreate,
        builder: (context, state) => AttendanceCreatePage(),
      ),
      GoRoute(
        path: AppRoute.payroll,
        name: AppRoute.payroll,
        builder: (context, state) => PayrollSalaryPage(),
      ),
      GoRoute(
        path: AppRoute.payrollCreate,
        name: AppRoute.payrollCreate,
        builder: (context, state) => PayrollCreatePage(),
      ),
      GoRoute(
        path: AppRoute.leave,
        name: AppRoute.leave,
        builder: (context, state) => LeavePage(),
      ),
      GoRoute(
        path: AppRoute.leaveCreate,
        name: AppRoute.leaveCreate,
        builder: (context, state) => LeaveCreatePage(),
      ),
      GoRoute(
        path: AppRoute.accountUpgrade,
        name: AppRoute.accountUpgrade,
        builder: (context, state) => AccountUpgradePage(),
      ),
      GoRoute(
        path: '${AppRoute.payrollPayslip}/:id',
        name: AppRoute.payrollPayslip,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return PayrollPayslipPage(id: id);
        },
      ),
      GoRoute(
        path: AppRoute.hrRule,
        name: AppRoute.hrRule,
        builder: (context, state) => HrRulePage(),
      ),
      GoRoute(
        path: AppRoute.printer,
        name: AppRoute.printer,
        builder: (context, state) => PrinterPage(),
      ),
      GoRoute(
        path: AppRoute.login,
        name: AppRoute.login,
        builder: (context, state) {
          String? message = state.extra as String?;
          return LoginScreen(
            showToast: message != null,
            toastDescription: message != null ? Text(message) : null,
            toastIcon: message != null
                ? Icon(
                    LucideIcons.circleCheck,
                    color: Colors.greenAccent,
                    size: FontSizeConfig.iconSize(context),
                  )
                : null,
          );
        },
      ),
    ],
  );
});
