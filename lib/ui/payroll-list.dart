import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/payroll.api.dart';
import 'package:pos/component/delete-dialog.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/component/payroll-card.dart';
import 'package:pos/localization/payroll-local.dart';
import 'package:pos/models/payroll.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';

class PayrollList extends ConsumerStatefulWidget {
  PayrollList({super.key, this.selectedData});
  final SelectedData? selectedData;

  @override
  ConsumerState<PayrollList> createState() => PayrollListState();
}

class PayrollListState extends ConsumerState<PayrollList> {
  late final PagingController<int, PayrollRecord> _pagingController;
  final int limit = 10;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, PayrollRecord>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(payrollProvider.notifier)
          .getAllPayroll(
            page: pageKey,
            limit: limit,
            userId: widget.selectedData?.userId,
            month: widget.selectedData?.startDate?.month,
            year: widget.selectedData?.startDate?.year,
          ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  void _delete(PayrollRecord payroll, bool isDark) {
    showDeleteDialog(
      context,
      title: PayrollLocaleScreenLocale.payrollDeleteConfirm.getString(context),
      isDark: isDark,
      submit: () async {
        await ref
            .read(payrollProvider.notifier)
            .deletePayroll(payroll.id)
            .then((data) {
              if (data) {
                ShowToast(
                  context,
                  description: Text(
                    PayrollLocaleScreenLocale.payrollDeleteSuccess.getString(
                      context,
                    ),
                  ),
                );
                context.pop();
                _pagingController.refresh();
              }
            })
            .catchError((err) {
              ShowToast(
                context,
                description: Text(
                  PayrollLocaleScreenLocale.payrollDeleteFail.getString(
                    context,
                  ),
                ),
                isError: true,
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final user = ref.watch(userStateProvider);
    ref.listen<SelectedData?>(selectedDataStateProvider, (prev, next) {
      _pagingController.refresh();
    });
    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) =>
          PagedListView<int, PayrollRecord>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<PayrollRecord>(
              itemBuilder: (context, payroll, index) {
                return InkWell(
                  onTap: () => context.pushNamed(
                    AppRoute.payrollPayslip,
                    pathParameters: {'id': payroll.id.toString()},
                  ),
                  splashColor: kPrimary.withOpacity(0.08),
                  child: PayrollCard(
                    payroll: payroll,
                    textColor: textColor,
                    subColor: subColor,
                    isDark: isDark,
                    onDelete:
                        (user != null &&
                            (isAdmin(user.role) || isManager(user.role)))
                        ? () => _delete(payroll, isDark)
                        : null,
                  ),
                );
              },
              firstPageProgressIndicatorBuilder: (_) => const LoadingWidget(),
              newPageProgressIndicatorBuilder: (_) => const LoadingWidget(),
              noItemsFoundIndicatorBuilder: (_) =>
                  NoItemFoundWidget(subColor: subColor),
            ),
          ),
    );
  }
}
