import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/date-select.dart';
import 'package:pos/component/user-select.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/ui/debt-list.dart';
import 'package:pos/localization/debt-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/description-widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DebtVoucherPage extends ConsumerStatefulWidget {
  const DebtVoucherPage({super.key});

  @override
  ConsumerState<DebtVoucherPage> createState() => _DebtVoucherPageState();
}

class _DebtVoucherPageState extends ConsumerState<DebtVoucherPage> {
  @override
  void dispose() {
    super.dispose();
    _clearSelectedData();
  }

  void _clearSelectedData() {
    ref.read(selectedDataStateProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final user = ref.watch(userStateProvider);
    final selectedData = ref.watch(selectedDataStateProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: DebtLocaleScreenLocale.debtTitle.getString(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user != null && (isAdmin(user.role) || isManager(user.role)))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DescriptionWidget(
                isDark: isDark,
                description: DebtLocaleScreenLocale.debtDescription.getString(
                  context,
                ),
                icon: LucideIcons.fileText,
                subColor: subColor,
              ),
            ),
          const SizedBox(height: 12),
          DebtLabel(textColor: textColor),
          const SizedBox(height: 12),
          // if (user != null && (isAdmin(user.role) || isManager(user.role)))
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: DateSelect(),
          ),
          Expanded(
            child: DebtListTile(
              userId: selectedData?.userId,
              startDate: selectedData?.startDate,
              endDate: selectedData?.endDate,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class DebtLabel extends ConsumerWidget {
  const DebtLabel({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimary, kSecondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            DebtLocaleScreenLocale.debtTitle.getString(context),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.2,
            ),
          ),
          if (user != null && (isAdmin(user.role) || isManager(user.role))) ...[
            const Spacer(),
            const UserSelect(),
          ],
        ],
      ),
    );
  }
}
