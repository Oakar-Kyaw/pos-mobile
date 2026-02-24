import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/localization/localization.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/utils/route-constant.dart';

class CustomerDrawer {
  final bool isLoggedIn;
  CustomerDrawer({this.isLoggedIn = false});

  Widget buildDrawer(BuildContext context) {
    // Read theme from a ProviderScope consumer
    return Consumer(
      builder: (context, ref, _) {
        final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
        final bgColor = isDark ? kBgDark : kBgLight;
        final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
        final textColor = isDark ? kTextDark : kTextLight;
        final subColor = isDark ? kTextSubDark : kTextSubLight;
        final dividerColor = isDark
            ? Colors.white.withOpacity(0.07)
            : const Color(0xFFE5E7EB);

        final languages = {
          'en': DrawerScreenLocale.drawerEnglish.getString(context),
          'mm': DrawerScreenLocale.drawerMyanmar.getString(context),
        };

        final menuItems = [
          _MenuItem(
            icon: LucideIcons.house,
            label: DrawerScreenLocale.drawerHome.getString(context),
            route: AppRoute.home,
          ),
          _MenuItem(
            icon: LucideIcons.tag,
            label: DrawerScreenLocale.drawerCategory.getString(context),
            route: AppRoute.category,
          ),
          _MenuItem(
            icon: LucideIcons.packageOpen,
            label: DrawerScreenLocale.drawerProduct.getString(context),
            route: AppRoute.product,
          ),
          _MenuItem(
            icon: LucideIcons.ticket,
            label: DrawerScreenLocale.drawerVoucher.getString(context),
            route: AppRoute.vouchers,
          ),
          _MenuItem(
            icon: LucideIcons.trendingUp,
            label: DrawerScreenLocale.drawerIncome.getString(context),
            route: AppRoute.income,
          ),
          _MenuItem(
            icon: LucideIcons.clipboardList,
            label: DrawerScreenLocale.drawerSaleReport.getString(context),
            route: AppRoute.saleReports,
          ),
          _MenuItem(
            icon: LucideIcons.receipt,
            label: DrawerScreenLocale.drawerExpense.getString(context),
            route: AppRoute.companyProfile,
          ),
        ];

        return Drawer(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: bgColor,
          child: SafeArea(
            child: Column(
              children: [
                // ── Header ────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, kSecondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          LucideIcons.shoppingCart,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        DrawerScreenLocale.drawerPosSystem.getString(context),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DrawerScreenLocale.drawerPosManagement.getString(
                          context,
                        ),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Menu Items ────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    children: [
                      // Nav items
                      ...menuItems.map(
                        (item) => _drawerItem(
                          context,
                          item: item,
                          isDark: isDark,
                          textColor: textColor,
                          dividerColor: dividerColor,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Divider(color: dividerColor, height: 1),
                      const SizedBox(height: 10),

                      // ── Theme toggle ────────────────
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isDark ? LucideIcons.sun : LucideIcons.moon,
                              color: kPrimary,
                              size: 16,
                            ),
                          ),
                          title: Text(
                            isDark
                                ? DrawerScreenLocale.drawerLight.getString(
                                    context,
                                  )
                                : DrawerScreenLocale.drawerDark.getString(
                                    context,
                                  ),
                            style: TextStyle(
                              fontSize: FontSizeConfig.body(context),
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => ref
                              .read(themeModeProvider.notifier)
                              .toggleTheme(),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ── Language select ─────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                LucideIcons.globe,
                                color: kPrimary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ShadSelect<String>(
                                decoration: const ShadDecoration(
                                  secondaryBorder: ShadBorder.none,
                                  secondaryFocusedBorder: ShadBorder.none,
                                ),
                                placeholder: Text(
                                  DrawerScreenLocale.drawerSelectLanguage
                                      .getString(context),
                                  style: TextStyle(
                                    color: subColor,
                                    fontSize: 13,
                                  ),
                                ),
                                selectedOptionBuilder: (context, value) => Text(
                                  languages[value]!,
                                  style: TextStyle(color: textColor),
                                ),
                                onChanged: (value) {
                                  if (value != null)
                                    localization.translate(value);
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Footer: Login / Profile ───────────
                Divider(height: 1, color: dividerColor),
                Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, kSecondary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      isLoggedIn ? LucideIcons.circleUser : LucideIcons.logIn,
                      color: Colors.white,
                      size: 20,
                    ),
                    title: Text(
                      isLoggedIn
                          ? DrawerScreenLocale.drawerProfile.getString(context)
                          : DrawerScreenLocale.drawerLogin.getString(context),
                      style: TextStyle(
                        fontSize: FontSizeConfig.body(context),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required _MenuItem item,
    required bool isDark,
    required Color textColor,
    required Color dividerColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(item.icon, color: kPrimary, size: 16),
        ),
        title: Text(
          item.label,
          style: TextStyle(
            fontSize: FontSizeConfig.body(context),
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          context.pushNamed(item.route);
        },
        hoverColor: kPrimary.withOpacity(0.06),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
