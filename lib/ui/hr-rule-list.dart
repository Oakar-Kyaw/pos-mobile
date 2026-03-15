import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/hr-rule.api.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/rule-card.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/utils/app-theme.dart';

class HrRuleList extends ConsumerStatefulWidget {
  const HrRuleList({super.key});

  @override
  ConsumerState<HrRuleList> createState() => _HrRuleListState();
}

class _HrRuleListState extends ConsumerState<HrRuleList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  BoxDecoration getContainerBoxDecorationByEven(Color dividerColor) {
    return BoxDecoration(
      color: Colors.transparent,
      border: Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
    );
  }

  BoxDecoration getContainerBoxDecorationByOdd(
    bool isDark,
    Color dividerColor,
  ) {
    return BoxDecoration(
      color: (isDark
          ? Colors.white.withOpacity(0.02)
          : Colors.black.withOpacity(0.01)),
      border: Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    final hrRulesAsync = ref.watch(hrRuleProvider);

    return hrRulesAsync.when(
      data: (data) {
        if (data.isEmpty) {
          return Text(VoucherScreenLocale.noItems.getString(context));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: data.length,
          separatorBuilder: (context, index) => SizedBox(height: 10),
          itemBuilder: (context, index) {
            final rule = data[index];
            return RuleCardComponent(
              textColor: textColor,
              subColor: subColor,
              rule: rule,
            );
          },
        );
      },
      error: (err, _) => Text("Something went wrong"),
      loading: () => Center(child: LoadingWidget()),
    );
  }
}
