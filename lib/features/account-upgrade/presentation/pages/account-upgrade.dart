import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
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
  static const int monthlyPrice = 59500;

  final List<UpgradePlan> plans = const [
    UpgradePlan(
      name: "1 Month",
      months: 1,
      price: 59500,
      discount: 0,
      savingText: null,
      popular: false,
    ),
    UpgradePlan(
      name: "3 Months",
      months: 3,
      price: 160650,
      discount: 10,
      savingText: "10% OFF",
      popular: true,
    ),
    UpgradePlan(
      name: "6 Months",
      months: 6,
      price: 357000,
      discount: 16,
      savingText: "1 Month FREE",
      popular: false,
    ),
    UpgradePlan(
      name: "1 Year",
      months: 12,
      price: 714000,
      discount: 17,
      savingText: "3 Months FREE",
      popular: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: "Upgrade Account",
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _HeaderSection(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = Responsive.isMobile(context);

              if (isMobile) {
                return Column(
                  children: plans.map((plan) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: UpgradePlanCard(
                        plan: plan,
                        monthlyPrice: monthlyPrice,
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
                  childAspectRatio: 1.25,
                ),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  return UpgradePlanCard(
                    plan: plans[index],
                    monthlyPrice: monthlyPrice,
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
          "Choose Your Plan",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: FontSizeConfig.title(context) + 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Upgrade your POS Master account and enjoy all premium features.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "59,500 MMK / month",
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
    required this.plan,
    required this.monthlyPrice,
  });

  final UpgradePlan plan;
  final int monthlyPrice;

  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  int get originalPrice => monthlyPrice * plan.months;

  int get saving => originalPrice - plan.price;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ShadCard(
          border: plan.popular
              ? ShadBorder.all(width: 1.5, color: kRed)
              : ShadBorder.all(width: 1, color: Colors.transparent),
          title: Padding(
            padding: const EdgeInsets.only(right: 70),
            child: Text(
              plan.name,
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
                      "${formatPrice(plan.price)} MMK",
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
                        "Save ${formatPrice(saving)} MMK",
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
                _PlanFeature(
                  icon: LucideIcons.check,
                  text: "All POS Master features",
                ),
                _PlanFeature(
                  icon: LucideIcons.check,
                  text: "Cloud-based POS system",
                ),
                _PlanFeature(
                  icon: LucideIcons.check,
                  text: "Sales & inventory management",
                ),
                _PlanFeature(
                  icon: LucideIcons.check,
                  text: "Reports & analytics",
                ),
                _PlanFeature(icon: LucideIcons.check, text: "Customer support"),
              ],
            ),
          ),
          footer: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showShadDialog(
                  context: context,
                  builder: (context) {
                    return UpgradeConfirmationDialog(plan: plan);
                  },
                );
              },
              child: const Text("Upgrade"),
            ),
          ),
        ),
        if (plan.savingText != null)
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
                plan.savingText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (plan.popular)
          Positioned(
            top: 32,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "POPULAR",
                style: TextStyle(
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

class UpgradeConfirmationDialog extends StatelessWidget {
  const UpgradeConfirmationDialog({super.key, required this.plan});

  final UpgradePlan plan;

  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ShadDialog(
        title: Text("Upgrade to ${plan.name}"),
        description: Text(
          "Your selected plan costs ${formatPrice(plan.price)} MMK.",
        ),
        actions: [
          ShadButton.outline(
            onPressed: () {
              context.pop();
            },
            child: const Text("Cancel"),
          ),
          ShadButton(
            onPressed: () {
              context.pop();

              showShadDialog(
                context: context,
                builder: (context) {
                  return const UpgradeContactDialog();
                },
              );
            },
            child: const Text("Contact Us"),
          ),
        ],
      ),
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

class UpgradePlan {
  const UpgradePlan({
    required this.name,
    required this.months,
    required this.price,
    required this.discount,
    required this.savingText,
    required this.popular,
  });

  final String name;
  final int months;
  final int price;
  final int discount;
  final String? savingText;
  final bool popular;
}
