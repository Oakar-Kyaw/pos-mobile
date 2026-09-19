import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/features/account-upgrade/domain/entites/plan.dart';
import 'package:pos/localization/account-upgrade.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

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
          footer: SizedBox(
            width: double.infinity,
            child: ShadButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return UpgradeContactDialog(planName: planUI.plan.name);
                  },
                );
              },
              child: Text(
                AccountUpgradeScreenLocale.upgradeButton.getString(context),
              ),
            ),
          ),
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

class UpgradeContactDialog extends StatelessWidget {
  const UpgradeContactDialog({super.key, this.planName});

  final String? planName;

  static const String phoneNumber = "09784727952";
  static const String emailAddress = "support@example.com";
  static const String viberNumber = "+959784727952";
  static const String telegramUsername = "@ja_7090";
  static const String whatsappNumber = "+959784727952";

  Future<void> _openUrl(BuildContext context, Uri uri) async {
    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open application")),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open application")),
        );
      }
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$label copied to clipboard")));
  }

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: Text(
        planName != null ? "Upgrade to $planName" : "Contact Us to Upgrade",
      ),
      description: const Text(
        "Choose a contact method below to finalize your upgrade with our support team.",
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          _ContactTile(
            icon: LucideIcons.phone,
            title: "Phone",
            value: phoneNumber,
            onTap: () => _openUrl(context, Uri.parse("tel:$phoneNumber")),
            onCopy: () =>
                _copyToClipboard(context, phoneNumber, "Phone number"),
          ),
          _ContactTile(
            icon: LucideIcons.mail,
            title: "Email",
            value: emailAddress,
            onTap: () => _openUrl(
              context,
              Uri.parse(
                "mailto:$emailAddress?subject=Account%20Upgrade%20Request",
              ),
            ),
            onCopy: () =>
                _copyToClipboard(context, emailAddress, "Email address"),
          ),
          _ContactTile(
            icon: LucideIcons.messageCircle,
            title: "Viber",
            value: viberNumber,
            onTap: () => _openUrl(
              context,
              Uri.parse(
                "viber://chat?number=${viberNumber.replaceAll('+', '')}",
              ),
            ),
            onCopy: () =>
                _copyToClipboard(context, viberNumber, "Viber number"),
          ),
          _ContactTile(
            icon: LucideIcons.send,
            title: "Telegram",
            value: telegramUsername,
            onTap: () => _openUrl(
              context,
              Uri.parse("https://t.me/${telegramUsername.replaceAll('@', '')}"),
            ),
            onCopy: () => _copyToClipboard(
              context,
              telegramUsername,
              "Telegram username",
            ),
          ),
          _ContactTile(
            icon: LucideIcons.messageSquare,
            title: "WhatsApp",
            value: whatsappNumber,
            onTap: () => _openUrl(
              context,
              Uri.parse("https://wa.me/${whatsappNumber.replaceAll('+', '')}"),
            ),
            onCopy: () =>
                _copyToClipboard(context, whatsappNumber, "WhatsApp number"),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ShadButton.outline(
              onPressed: () => context.pop(),
              child: const Text("Close"),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    required this.onCopy,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: kGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.copy, size: 16),
              onPressed: onCopy,
              tooltip: "Copy $title",
            ),
          ],
        ),
      ),
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
