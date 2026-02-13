import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/main.dart';
import 'package:pos/src/category.dart';
import 'package:pos/src/company-profile.dart';
import 'package:pos/src/home.dart';
import 'package:pos/src/login.dart';
import 'package:pos/src/product.dart';
import 'package:pos/src/setting.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final GoRouter goRouter = GoRouter(
  initialLocation: AppRoute.home,
  routes: [
    GoRoute(
      path: AppRoute.home,
      name: AppRoute.home,
      builder: (context, state) =>
          ShadToaster(child: const MyHomePage(title: 'POS App')),
    ),
    GoRoute(
      path: AppRoute.settings,
      name: AppRoute.settings,
      builder: (context, state) => ShadToaster(child: Setting()),
    ),
    GoRoute(
      path: AppRoute.category,
      name: AppRoute.category,
      builder: (context, state) => ShadToaster(child: const CategoryPage()),
    ),
    GoRoute(
      path: AppRoute.companyProfile,
      name: AppRoute.companyProfile,
      builder: (context, state) =>
          ShadToaster(child: const CompanyProfilePage()),
    ),
    GoRoute(
      path: AppRoute.product,
      name: AppRoute.product,
      builder: (context, state) => ShadToaster(child: const ProductPage()),
    ),
    GoRoute(
      path: AppRoute.login,
      name: AppRoute.login,
      builder: (context, state) {
        String? message = state.extra as String?;
        return message != null
            ? ShadToaster(
                child: LoginScreen(
                  showToast: true,
                  toastDescription: Text(message),
                  toastIcon: Icon(
                    LucideIcons.circleCheck,
                    color: Colors.greenAccent,
                    size: FontSizeConfig.iconSize(context),
                  ),
                ),
              )
            : ShadToaster(child: LoginScreen());
      },
    ),
  ],
);
