import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/features/profile/presentation/widget/company-profile-tab.dart';
import 'package:pos/features/profile/presentation/widget/user-profile-tab.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final user = ref.watch(userStateProvider);
    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    if (user == null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: CustomAppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(LucideIcons.arrowLeft),
          ),
          title: DrawerScreenLocale.drawerProfile.getString(context),
        ),
        body: const Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    }

    final showCompanyTab = isAdmin(user.role);
    final tabCount = showCompanyTab ? 2 : 1;

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: CustomAppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(LucideIcons.arrowLeft),
          ),
          title: DrawerScreenLocale.drawerProfile.getString(context),
          bottom: showCompanyTab
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(46),
                  child: TabBar(
                    indicatorColor: kPrimary,
                    labelColor: textColor,
                    unselectedLabelColor: subColor,
                    tabs: [
                      Tab(
                        icon: const Icon(LucideIcons.user, size: 16),
                        text: DrawerScreenLocale.drawerProfile.getString(
                          context,
                        ),
                      ),
                      Tab(
                        icon: const Icon(LucideIcons.building2, size: 16),
                        text: DrawerScreenLocale.drawerCompany.getString(
                          context,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
        body: showCompanyTab
            ? TabBarView(
                children: [
                  UserProfileTab(user: user),
                  const CompanyProfileTab(),
                ],
              )
            : UserProfileTab(user: user),
      ),
    );
  }
}
