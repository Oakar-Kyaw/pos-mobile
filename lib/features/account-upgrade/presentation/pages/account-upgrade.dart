import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/core/widgets/upgrade-pay-dialog.dart';
import 'package:pos/features/account-upgrade/domain/entites/plan.dart';
import 'package:pos/features/account-upgrade/presentation/riverpod/plan-provider.dart';
import 'package:pos/features/account-upgrade/presentation/utils/plan-icon-mapper.dart';
import 'package:pos/features/account-upgrade/presentation/utils/plan-mapper.dart';
import 'package:pos/localization/account-upgrade.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/responsive.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AccountUpgradePage extends ConsumerStatefulWidget {
  const AccountUpgradePage({super.key});

  @override
  ConsumerState<AccountUpgradePage> createState() => _AccountUpgradePage();
}

class _AccountUpgradePage extends ConsumerState<AccountUpgradePage> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final plan = ref.watch(planProvider);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: AccountUpgradeScreenLocale.upgradeTitle.getString(context),
      ),
      body: plan.when(
        data: (pl) {
          final bool isMobile = Responsive.isMobile(context);
          final int crossCount = isMobile ? 1 : 2;
          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.count(
              crossAxisCount: crossCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 20,
              children: List<Widget>.generate(pl.length, (index) {
                final planData = pl[index];
                return Stack(
                  children: [
                    PlanCard(planData: planData),
                    DiscountCircle(planData: planData),
                  ],
                );
              }),
            ),
          );
        },
        error: (err, _) => Text("Something went wrong"),
        loading: () => LoadingWidget(),
      ),
    );
  }
}

class DiscountCircle extends StatelessWidget {
  const DiscountCircle({super.key, required this.planData});

  final Plan planData;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      right: 10,
      child: Column(
        children: [
          if (planData.discountPercent > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Container(
                height: 45,
                width: 45,
                color: kRed,
                child: Center(
                  child: Text(
                    "${planData.discountPercent.toString()}%",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          if (planData.isPopular) Text("Popular"),
        ],
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.planData});

  final Plan planData;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      border: planData.isPopular
          ? ShadBorder.all(width: 1, color: kRed)
          : ShadBorder.none,
      title: Text(
        planLocaleMap[planData.name]!.getString(context),
        style: TextStyle(fontSize: FontSizeConfig.title(context)),
      ),
      footer: GradientSubmitButton(
        onPressed: () {
          showShadDialog(
            context: context,
            builder: (context) => AccountUpgradeDialog(plan: planData),
          );
        },
        text: AccountUpgradeScreenLocale.upgradeTitle.getString(context),
        width: double.infinity,
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
        child: ListView(
          // The list expands to fit all children.
          shrinkWrap: true,
          children: planData.planFeatures.map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Icon(iconMap[e.icon], color: kGreenSecondary),
                  const SizedBox(width: 10),
                  Text(
                    planFeatureKeys[e.key]?.getString(context) ?? e.key,
                    style: const TextStyle(color: kGreen),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
