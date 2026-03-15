import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/component/accent-bar.dart';
import 'package:pos/localization/hr-rule-local.dart';
import 'package:pos/models/hr-rule.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/badge.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

String getTitleByHrRuleType(String title) {
  switch (title) {
    case 'OVERTIME':
      return HrRuleLocaleScreen.hrRuleOvertime;
    case 'LEAVE_ALLOW':
      return HrRuleLocaleScreen.hrRuleLeave;
    case 'EARLY_LEAVE':
      return HrRuleLocaleScreen.hrRuleEarlyLeave;
    default:
      return HrRuleLocaleScreen.hrRuleDeduct;
  }
}

IconData getIconByHrRuleType(String type) {
  switch (type) {
    case 'DEDUCT':
      return LucideIcons.badgeMinus;

    case 'EARLY_LEAVE':
      return LucideIcons.logOut;

    case 'OVERTIME':
      return LucideIcons.clockPlus;

    case 'LEAVE_ALLOW':
      return LucideIcons.calendarCheck;

    default:
      return Icons.help_rounded;
  }
}

class RuleCardComponent extends StatelessWidget {
  RuleCardComponent({
    super.key,
    required this.textColor,
    required this.subColor,
    required this.rule,
  });

  final Color textColor;
  final Color subColor;
  final HrRule rule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccentBar(hasDebt: false),

          const SizedBox(width: 12),

          /// IMPORTANT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BadgeWidget(
                  icon: getIconByHrRuleType(rule.type),
                  label: getTitleByHrRuleType(rule.type).getString(context),
                  color: kRed,
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                RowWidget(
                  subColor: subColor,
                  textColor: textColor,
                  title: HrRuleLocaleScreen.hrRuleByMinute.getString(context),
                  amount: rule.thresholdMinute.toString(),
                ),
                const SizedBox(height: 12),
                RowWidget(
                  subColor: subColor,
                  textColor: textColor,
                  title: HrRuleLocaleScreen.hrRuleByDay.getString(context),
                  amount: rule.thresholdDays.toString(),
                ),
                const SizedBox(height: 12),
                RowWidget(
                  subColor: subColor,
                  textColor: textColor,
                  title: HrRuleLocaleScreen.hrRulePercent.getString(context),
                  amount: rule.thresholdAmountPercent.toString(),
                ),
                const SizedBox(height: 12),
                RowWidget(
                  subColor: subColor,
                  textColor: textColor,
                  title: HrRuleLocaleScreen.hrRuleAmount.getString(context),
                  amount: rule.thresholdAmount.toString(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RowWidget extends StatelessWidget {
  const RowWidget({
    super.key,
    required this.subColor,
    required this.textColor,
    required this.title,
    required this.amount,
  });

  final Color subColor;
  final Color textColor;
  final String title;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: TextStyle(color: subColor)),
        const Spacer(),
        Text(
          amount,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
      ],
    );
  }
}
