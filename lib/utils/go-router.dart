import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/riverpod/login-check.dart';
import 'package:pos/src/account.dart';
import 'package:pos/src/category.dart';
import 'package:pos/src/company-profile.dart';
import 'package:pos/src/create-voucher.dart';
import 'package:pos/src/general-expense.dart';
import 'package:pos/src/home.dart';
import 'package:pos/src/income.dart';
import 'package:pos/src/login.dart';
import 'package:pos/src/product.dart';
import 'package:pos/src/receipt.dart';
import 'package:pos/src/sale-report.dart';
import 'package:pos/src/setting.dart';
import 'package:pos/src/voucher.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
        builder: (context, state) => VoucherTablePage(),
      ),
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
