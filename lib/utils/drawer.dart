import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/localization/localization.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/utils/route-constant.dart';

class CustomerDrawer {
  final bool isLoggedIn;

  CustomerDrawer({this.isLoggedIn = false});

  Widget buildDrawer(BuildContext context) {
    final theme = ShadTheme.of(context);

    final languages = {
      'en': DrawerScreenLocale.drawerEnglish.getString(context),
      'mm': DrawerScreenLocale.drawerMyanmar.getString(context),
    };

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            // ===== MENU LIST =====
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(
                    context,
                    title: DrawerScreenLocale.drawerHome.getString(context),
                    route: AppRoute.home,
                  ),
                  // _drawerItem(
                  //   context,
                  //   title: DrawerScreenLocale.drawerCompany.getString(context),
                  //   route: AppRoute.companyProfile,
                  // ),
                  const Divider(height: 1),
                  _drawerItem(
                    context,
                    title: DrawerScreenLocale.drawerCategory.getString(context),
                    route: AppRoute.category,
                  ),
                  const Divider(height: 1),
                  _drawerItem(
                    context,
                    title: DrawerScreenLocale.drawerProduct.getString(context),
                    route: AppRoute.product,
                  ),
                  const Divider(height: 1),
                  _drawerItem(
                    context,
                    title: DrawerScreenLocale.drawerVoucher.getString(context),
                    route: AppRoute.vouchers,
                  ),
                  const Divider(height: 1),
                  _drawerItem(
                    context,
                    title: DrawerScreenLocale.drawerIncome.getString(context),
                    route: AppRoute.income,
                  ),
                  const Divider(height: 1),
                  _drawerItem(
                    context,
                    title: DrawerScreenLocale.drawerSaleReport.getString(
                      context,
                    ),
                    route: AppRoute.saleReports,
                  ),
                  const Divider(height: 1),
                  _drawerItem(
                    context,
                    title: DrawerScreenLocale.drawerExpense.getString(context),
                    route: AppRoute.companyProfile,
                  ),
                  const Divider(height: 1),
                  // ===== LANGUAGE SELECT =====
                  ListTile(
                    title: SizedBox(
                      width:
                          MediaQuery.of(context).size.width *
                          0.85, // adjust as you like
                      child: ShadSelect<String>(
                        decoration: const ShadDecoration(
                          secondaryBorder: ShadBorder.none,
                          secondaryFocusedBorder: ShadBorder.none,
                        ),
                        placeholder: Text(
                          DrawerScreenLocale.drawerSelectLanguage.getString(
                            context,
                          ),
                        ),
                        selectedOptionBuilder: (context, value) =>
                            Text(languages[value]!),
                        onChanged: (value) {
                          if (value != null) localization.translate(value);
                        },
                        options: languages.entries
                            .map(
                              (e) => ShadOption(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),

            const Divider(height: 1),
            // ===== LOGIN / PROFILE =====
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: Icon(isLoggedIn ? Icons.person : Icons.login, size: 20),
              title: Text(
                isLoggedIn
                    ? DrawerScreenLocale.drawerProfile.getString(context)
                    : DrawerScreenLocale.drawerLogin.getString(context),
                style: TextStyle(fontSize: FontSizeConfig.body(context)),
              ),
              onTap: () {
                Navigator.pop(context);
                if (isLoggedIn) {
                  context.pushNamed(AppRoute.profile);
                } else {
                  context.pushNamed(AppRoute.login);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===== REUSABLE DRAWER ITEM =====
  Widget _drawerItem(
    BuildContext context, {
    required String title,
    required String route,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(
        title,
        style: TextStyle(fontSize: FontSizeConfig.body(context)),
      ),
      onTap: () {
        Navigator.pop(context);
        context.pushNamed(route);
      },
    );
  }
}
