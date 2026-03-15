import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/general-expense.api.dart';
import 'package:pos/component/delete-icon.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/localization/general-expense-local.dart';
import 'package:pos/models/general-expense.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class GeneralExpenseCard extends ConsumerStatefulWidget {
  const GeneralExpenseCard({
    super.key,
    required PagingController<int, GeneralExpense> pagingController,
    required this.surfaceColor,
    required this.isDark,
    required this.textColor,
    required this.subColor,
  }) : _pagingController = pagingController;

  final PagingController<int, GeneralExpense> _pagingController;
  final Color surfaceColor;
  final bool isDark;
  final Color textColor;
  final Color subColor;

  @override
  ConsumerState<GeneralExpenseCard> createState() => _GeneralExpenseCardState();
}

class _GeneralExpenseCardState extends ConsumerState<GeneralExpenseCard> {
  void _delete(int id) {
    // print("Delete expense id: $id");
    ref
        .read(generalExpenseProvider.notifier)
        .deleteExpense(id)
        .then((data) {
          if (data) {
            ShowToast(
              context,
              description: Text(
                GeneralExpenseLocale.deleteSuccess.getString(context),
              ),
            );
            widget._pagingController.refresh();
          }
        })
        .catchError((err) {
          ShowToast(
            context,
            description: Text(
              GeneralExpenseLocale.deleteFail.getString(context),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userStateProvider);

    BoxDecoration generalExpenseBoxDecoration = BoxDecoration(
      color: widget.surfaceColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: widget.isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.06),
      ),
      boxShadow: [
        BoxShadow(
          color: widget.isDark
              ? kPrimary.withOpacity(0.1)
              : Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

    return Expanded(
      child: PagingListener(
        controller: widget._pagingController,
        builder: (context, state, fetchNextPage) =>
            PagedListView<int, GeneralExpense>(
              state: state,
              fetchNextPage: fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate<GeneralExpense>(
                itemBuilder: (context, expense, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: generalExpenseBoxDecoration,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GeneralExpenseTitle(
                              isDark: widget.isDark,
                              textColor: widget.textColor,
                              expense: expense,
                            ),
                            const SizedBox(height: 10),
                            GeneralExpenseDate(
                              subColor: widget.subColor,
                              expense: expense,
                              textColor: widget.textColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              GeneralExpenseLocale.expenseReason.getString(
                                context,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.subColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              expense.reason ?? '-',
                              style: TextStyle(
                                fontSize: FontSizeConfig.body(context),
                                color: widget.textColor,
                              ),
                            ),
                          ],
                        ),
                        if (user != null &&
                            (isAdmin(user.role) || isManager(user.role)))
                          DeleteIcon(
                            onDelete: () => _delete(expense.id),
                            top: 0,
                            right: 0,
                          ),
                      ],
                    ),
                  );
                },
                firstPageProgressIndicatorBuilder: (_) =>
                    const Center(child: LoadingWidget()),
                newPageProgressIndicatorBuilder: (_) => const LoadingWidget(),
                noItemsFoundIndicatorBuilder: (_) =>
                    NoItemGeneralExpense(subColor: widget.subColor),
              ),
            ),
      ),
    );
  }
}

class GeneralExpenseDate extends StatelessWidget {
  const GeneralExpenseDate({
    super.key,
    required this.subColor,
    required this.textColor,
    required this.expense,
  });

  final Color subColor;
  final GeneralExpense expense;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(LucideIcons.calendar, size: 12, color: subColor),
        const SizedBox(width: 6),
        Text(
          DateFormat('yyyy-MM-dd').format(expense.date),
          style: TextStyle(
            fontSize: FontSizeConfig.body(context),
            color: subColor,
          ),
        ),
        Spacer(),
        Text(
          formatAmount(expense.amount),
          style: TextStyle(
            fontSize: FontSizeConfig.title(context),
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class GeneralExpenseTitle extends StatelessWidget {
  const GeneralExpenseTitle({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.expense,
  });

  final bool isDark;
  final Color textColor;
  final GeneralExpense expense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            LucideIcons.walletMinimal,
            color: kPrimary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            expense.title,
            style: TextStyle(
              fontSize: FontSizeConfig.title(context),
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

class NoItemGeneralExpense extends StatelessWidget {
  const NoItemGeneralExpense({super.key, required this.subColor});

  final Color subColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.ticket, color: kPrimary, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            GeneralExpenseLocale.expenseNoItems.getString(context),
            style: TextStyle(color: subColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
