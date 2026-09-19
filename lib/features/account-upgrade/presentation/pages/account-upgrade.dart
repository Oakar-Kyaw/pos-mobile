import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/features/account-upgrade/domain/entites/plan.dart';
import 'package:pos/features/account-upgrade/presentation/widgets/upgrade-pay-dialog.dart';
import 'package:pos/localization/account-upgrade.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/responsive.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountUpgradePage extends ConsumerStatefulWidget {
  const AccountUpgradePage({super.key});

  @override
  ConsumerState<AccountUpgradePage> createState() => _AccountUpgradePageState();
}

class _AccountUpgradePageState extends ConsumerState<AccountUpgradePage> {
  static const double baseMonthlyPrice = 59500;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;

    final List<UpgradePlanUI> plans = [
      UpgradePlanUI(
        plan: Plan(
          id: 1,
          name: '1 Month',
          title: 'Basic Plan',
          month: 1,
          durationDays: 30,
          priceMMK: '59500',
          priceUSD: '20',
          discountPercent: 0,
          isPopular: false,
          isActive: true,
          existBranch: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
          planFeatures: [],
        ),
        nameKey: AccountUpgradeScreenLocale.monthOne,
        savingTextKey: null,
      ),
      UpgradePlanUI(
        plan: Plan(
          id: 2,
          name: '3 Months',
          title: 'Standard Plan',
          month: 3,
          durationDays: 90,
          priceMMK: '160650',
          priceUSD: '55',
          discountPercent: 10,
          isPopular: true,
          isActive: true,
          existBranch: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
          planFeatures: [],
        ),
        nameKey: AccountUpgradeScreenLocale.monthThree,
        savingTextKey: AccountUpgradeScreenLocale.tenPercentOff,
      ),
      UpgradePlanUI(
        plan: Plan(
          id: 3,
          name: '6 Months',
          title: 'Pro Plan',
          month: 6,
          durationDays: 180,
          priceMMK: '357000',
          priceUSD: '110',
          discountPercent: 15,
          isPopular: false,
          isActive: true,
          existBranch: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
          planFeatures: [],
        ),
        nameKey: AccountUpgradeScreenLocale.monthSix,
        savingTextKey: AccountUpgradeScreenLocale.oneMonthFree,
      ),
      UpgradePlanUI(
        plan: Plan(
          id: 4,
          name: '1 Year',
          title: 'Enterprise Plan',
          month: 12,
          durationDays: 365,
          priceMMK: '714000',
          priceUSD: '220',
          discountPercent: 25,
          isPopular: false,
          isActive: true,
          existBranch: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
          planFeatures: [],
        ),
        nameKey: AccountUpgradeScreenLocale.monthTwelve,
        savingTextKey: AccountUpgradeScreenLocale.threeMonthsFree,
      ),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: AccountUpgradeScreenLocale.upgradeTitle.getString(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const _HeaderSection(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = Responsive.isMobile(context);

              if (isMobile) {
                return Column(
                  children: plans.map((planUI) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: UpgradePlanCard(
                        planUI: planUI,
                        baseMonthlyPrice: baseMonthlyPrice,
                      ),
                    );
                  }).toList(),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.15,
                ),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  return UpgradePlanCard(
                    planUI: plans[index],
                    baseMonthlyPrice: baseMonthlyPrice,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
          const UpgradeContactCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AccountUpgradeScreenLocale.chooseYourPlan.getString(context),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: FontSizeConfig.title(context) + 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AccountUpgradeScreenLocale.upgradeSubtitle.getString(context),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AccountUpgradeScreenLocale.mmkPerMonth.getString(context),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: kGreen,
            fontSize: FontSizeConfig.body(context) + 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class UpgradePlanCard extends StatelessWidget {
  const UpgradePlanCard({
    super.key,
    required this.planUI,
    required this.baseMonthlyPrice,
  });

  final UpgradePlanUI planUI;
  final double baseMonthlyPrice;

  String formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    final double actualPrice = double.tryParse(planUI.plan.priceMMK) ?? 0.0;
    final double originalPrice = baseMonthlyPrice * planUI.plan.month;
    final double saving = originalPrice - actualPrice;

    final List<String> defaultFeatures = [
      AccountUpgradeScreenLocale.featureAllPos.getString(context),
      AccountUpgradeScreenLocale.featureCloud.getString(context),
      AccountUpgradeScreenLocale.featureSalesInventory.getString(context),
      AccountUpgradeScreenLocale.featureReports.getString(context),
      AccountUpgradeScreenLocale.featureSupport.getString(context),
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ShadCard(
          border: planUI.plan.isPopular
              ? ShadBorder.all(width: 1.5, color: kRed)
              : ShadBorder.all(width: 1, color: Colors.transparent),
          title: Padding(
            padding: const EdgeInsets.only(right: 70),
            child: Text(
              planUI.nameKey.getString(context),
              style: TextStyle(
                fontSize: FontSizeConfig.title(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${formatPrice(actualPrice)} MMK",
                      style: TextStyle(
                        fontSize: FontSizeConfig.title(context) + 2,
                        fontWeight: FontWeight.bold,
                        color: kGreen,
                      ),
                    ),
                  ],
                ),
                if (saving > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "${formatPrice(originalPrice)} MMK",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${AccountUpgradeScreenLocale.upgradeSave.getString(context)} ${formatPrice(saving)} MMK",
                        style: const TextStyle(
                          color: kGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 10),
                if (planUI.plan.planFeatures.isNotEmpty)
                  ...planUI.plan.planFeatures.map(
                    (feature) => _PlanFeature(
                      icon: LucideIcons.check,
                      text: feature.value,
                    ),
                  )
                else
                  ...defaultFeatures.map(
                    (featureText) => _PlanFeature(
                      icon: LucideIcons.check,
                      text: featureText,
                    ),
                  ),
              ],
            ),
          ),
          // footer: SizedBox(
          //   width: double.infinity,
          //   child: ShadButton(
          //     onPressed: () {
          //       showDialog(
          //         context: context,
          //         builder: (context) {
          //           return AccountUpgradeDialog(plan: planUI.plan);
          //         },
          //       );
          //     },
          //     child: Text(
          //       AccountUpgradeScreenLocale.upgradeButton.getString(context),
          //     ),
          //   ),
          // ),
        ),
        if (planUI.savingTextKey != null)
          Positioned(
            top: -8,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kRed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                planUI.savingTextKey!.getString(context),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (planUI.plan.isPopular)
          Positioned(
            top: 32,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AccountUpgradeScreenLocale.popular.getString(context),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class UpgradeContactCard extends StatelessWidget {
  const UpgradeContactCard({super.key});

  static const String viberNumber = "+959784727952";
  static const String phoneNumber = "09784727952";
  static const String telegramUsername = "ja_7090";
  static const String facebookUrl =
      "https://www.facebook.com/oakar.kyaw.260188";
  static const String whatsappNumber = "959784727952";

  Future<void> _openUrl(BuildContext context, Uri uri) async {
    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open this app")),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open this app")),
        );
      }
    }
  }

  void _openViber(BuildContext context) {
    _openUrl(context, Uri.parse("viber://chat?number=$viberNumber"));
  }

  void _openTelegram(BuildContext context) {
    _openUrl(context, Uri.parse("https://t.me/$telegramUsername"));
  }

  void _openFacebook(BuildContext context) {
    _openUrl(context, Uri.parse(facebookUrl));
  }

  void _openWhatsApp(BuildContext context) {
    _openUrl(context, Uri.parse("https://wa.me/$whatsappNumber"));
  }

  void _callPhone(BuildContext context) {
    _openUrl(context, Uri.parse("tel:$phoneNumber"));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: kGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.headphones, color: kGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upgrade your account?",
                        style: TextStyle(
                          fontSize: FontSizeConfig.title(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Contact us to upgrade your account.",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Connect with us",
              style: TextStyle(
                fontSize: FontSizeConfig.body(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ContactButton(
                  icon: LucideIcons.messageCircle,
                  label: "Viber",
                  onPressed: () => _openViber(context),
                ),
                _ContactButton(
                  icon: LucideIcons.send,
                  label: "Telegram",
                  onPressed: () => _openTelegram(context),
                ),
                _ContactButton(
                  icon: Icons.facebook,
                  label: "Facebook",
                  onPressed: () => _openFacebook(context),
                ),
                _ContactButton(
                  icon: LucideIcons.messageSquare,
                  label: "WhatsApp",
                  onPressed: () => _openWhatsApp(context),
                ),
                _ContactButton(
                  icon: LucideIcons.phone,
                  label: "Call Us +959784727952",
                  onPressed: () => _callPhone(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UpgradeContactDialog extends StatelessWidget {
  const UpgradeContactDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text("Contact Us to Upgrade"),
      description: const Text(
        "Choose any method below to contact us and complete your upgrade.",
      ),
      actions: [
        ShadButton(
          onPressed: () {
            context.pop();
          },
          child: const Text("Close"),
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text(
          "Viber: +959784727952\n"
          "Telegram: @ja_7090\n"
          "WhatsApp: +959784727952\n"
          "Phone: 09784727952",
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _PlanFeature extends StatelessWidget {
  const _PlanFeature({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kGreenSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: kGreen)),
          ),
        ],
      ),
    );
  }
}

class UpgradePlanUI {
  final Plan plan;
  final String nameKey;
  final String? savingTextKey;

  const UpgradePlanUI({
    required this.plan,
    required this.nameKey,
    required this.savingTextKey,
  });
}
