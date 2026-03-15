import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/general-expense.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/date-select.dart';
import 'package:pos/component/user-select.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/general-expense-local.dart';
import 'package:pos/models/general-expense.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/ui/general-expense-card.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/description-widget.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class GeneralExpensePage extends ConsumerStatefulWidget {
  const GeneralExpensePage({super.key});

  @override
  ConsumerState<GeneralExpensePage> createState() => _GeneralExpensePageState();
}

class _GeneralExpensePageState extends ConsumerState<GeneralExpensePage> {
  final int limit = 20;
  SelectedData? selectedData;

  late final PagingController<int, GeneralExpense> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, GeneralExpense>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(generalExpenseProvider.notifier)
          .fetchExpenses(
            page: pageKey,
            limit: limit,
            userId: selectedData?.userId,
            startDate: selectedData?.startDate,
            endDate: selectedData?.endDate,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final user = ref.watch(userStateProvider);
    ref.listen<SelectedData?>(selectedDataStateProvider, (prev, next) {
      selectedData = next;
      _pagingController.refresh();
    });
    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: DrawerScreenLocale.drawerExpense.getString(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DescriptionWidget(
              isDark: isDark,
              description: GeneralExpenseLocale.addExpense.getString(context),
              icon: LucideIcons.dollarSign,
              subColor: subColor,
            ),
            const SizedBox(height: 20),
            GradientSubmitButton(
              onPressed: () async {
                await context.pushNamed(AppRoute.generalExpenseCreate);
                _pagingController.refresh();
              },
              text: GeneralExpenseLocale.expenseButton.getString(context),
              width: 160,
            ),
            const SizedBox(height: 20),
            if (isAdmin(user!.role) || isManager(user.role)) ...[
              UserSelect(),
              SizedBox(height: 10),
              DateSelect(),
              SizedBox(height: 10),
            ],
            GeneralExpenseCard(
              pagingController: _pagingController,
              surfaceColor: surfaceColor,
              isDark: isDark,
              textColor: textColor,
              subColor: subColor,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
