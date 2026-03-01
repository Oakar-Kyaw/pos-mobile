import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/general-expense.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/table-cell.dart';
import 'package:pos/component/table-header.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/general-expense-local.dart';
import 'package:pos/models/general-expense.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/expense.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class GeneralExpensePage extends ConsumerStatefulWidget {
  const GeneralExpensePage({super.key});

  @override
  ConsumerState<GeneralExpensePage> createState() => _GeneralExpensePageState();
}

class _GeneralExpensePageState extends ConsumerState<GeneralExpensePage> {
  final int limit = 20;
  late final PagingController<int, GeneralExpense> _pagingController =
      PagingController<int, GeneralExpense>(
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => ref
            .read(generalExpenseProvider.notifier)
            .fetchExpenses(page: pageKey, limit: limit),
      );
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE5E7EB);
    final rowHoverColor = isDark
        ? kPrimary.withOpacity(0.06)
        : kPrimary.withOpacity(0.04);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: DrawerScreenLocale.drawerExpense.getString(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // ── Description banner ──────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(isDark ? 0.15 : 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: kPrimary.withOpacity(isDark ? 0.3 : 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.dollarSign,
                      color: kPrimary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      GeneralExpenseLocale.addExpense.getString(context),
                      style: TextStyle(
                        fontSize: FontSizeConfig.body(context),
                        color: subColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Section label ────────────────────────
            Row(
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
                  GeneralExpenseLocale.expenseForm.getString(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? kTextDark : kTextLight,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Form Card ────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? kPrimary.withOpacity(0.1)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GeneralExpenseForm(
                onSaved: () {
                  _pagingController.refresh(); // refresh table
                },
              ),
            ),

            const SizedBox(height: 25),

            // ── Table / List ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? kPrimary.withOpacity(0.1)
                          : Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // ── Table header ──────────────────
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kPrimary.withOpacity(isDark ? 0.25 : 0.08),
                            kSecondary.withOpacity(isDark ? 0.15 : 0.04),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        border: Border(
                          bottom: BorderSide(color: dividerColor, width: 1),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                          4: FlexColumnWidth(3),
                        },
                        children: [
                          TableRow(
                            children: [
                              buildTableHeader(
                                GeneralExpenseLocale.expenseNo.getString(
                                  context,
                                ),
                                context,
                                textColor,
                              ),
                              buildTableHeader(
                                GeneralExpenseLocale.expenseTitle.getString(
                                  context,
                                ),
                                context,
                                textColor,
                              ),
                              buildTableHeader(
                                GeneralExpenseLocale.expenseDate.getString(
                                  context,
                                ),
                                context,
                                textColor,
                              ),
                              buildTableHeader(
                                GeneralExpenseLocale.expenseAmount.getString(
                                  context,
                                ),
                                context,
                                textColor,
                                alignRight: true,
                              ),
                              buildTableHeader(
                                GeneralExpenseLocale.expenseReason.getString(
                                  context,
                                ),
                                context,
                                textColor,
                                alignRight: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Paged rows ────────────────────
                    Expanded(
                      child: PagingListener(
                        controller: _pagingController,
                        builder: (context, state, fetchNextPage) =>
                            PagedListView<int, GeneralExpense>(
                              state: state,
                              fetchNextPage: fetchNextPage,
                              builderDelegate:
                                  PagedChildBuilderDelegate<GeneralExpense>(
                                    itemBuilder: (context, expense, index) {
                                      final isEven = index % 2 == 0;
                                      return InkWell(
                                        // onTap: () => context.pushNamed(
                                        //   AppRoute.receipt,
                                        //   extra: voucher.id,
                                        // ),
                                        splashColor: kPrimary.withOpacity(0.08),
                                        highlightColor: rowHoverColor,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isEven
                                                ? Colors.transparent
                                                : (isDark
                                                      ? Colors.white
                                                            .withOpacity(0.02)
                                                      : Colors.black
                                                            .withOpacity(0.01)),
                                            border: Border(
                                              bottom: BorderSide(
                                                color: dividerColor,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          child: Table(
                                            columnWidths: const {
                                              0: FlexColumnWidth(1),
                                              1: FlexColumnWidth(2),
                                              2: FlexColumnWidth(2),
                                              3: FlexColumnWidth(2),
                                              4: FlexColumnWidth(3),
                                            },
                                            children: [
                                              TableRow(
                                                children: [
                                                  buildTableCell(
                                                    "${index + 1}",
                                                    subColor,
                                                  ),
                                                  buildTableCell(
                                                    expense.title,
                                                    textColor,
                                                    highlight: true,
                                                  ),
                                                  buildTableCell(
                                                    DateFormat(
                                                      'yyyy-MM-dd',
                                                    ).format(expense.date),
                                                    subColor,
                                                  ),
                                                  buildTableCell(
                                                    formatAmount(
                                                      expense.amount,
                                                    ),
                                                    textColor,
                                                    alignRight: true,
                                                  ),
                                                  buildTableCell(
                                                    expense.reason ?? '-',
                                                    textColor,
                                                    alignRight: true,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },

                                    firstPageProgressIndicatorBuilder: (_) =>
                                        Center(
                                          child: CircularProgressIndicator(
                                            color: kPrimary,
                                          ),
                                        ),
                                    newPageProgressIndicatorBuilder: (_) =>
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: kPrimary,
                                            ),
                                          ),
                                        ),
                                    noItemsFoundIndicatorBuilder: (_) => Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: kPrimary.withOpacity(0.08),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              LucideIcons.ticket,
                                              color: kPrimary,
                                              size: 32,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            GeneralExpenseLocale.expenseNoItems
                                                .getString(context),
                                            style: TextStyle(
                                              color: subColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
