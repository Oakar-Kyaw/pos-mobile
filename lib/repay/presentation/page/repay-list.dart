import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/component/delete-dialog.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/component/repay-card.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/localization/repay-local.dart';
import 'package:pos/models/repayment.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/responsive.dart';
import 'package:pos/utils/shad-toaster.dart';

class RepaymentList extends ConsumerStatefulWidget {
  const RepaymentList({super.key, this.userId, this.startDate, this.endDate});

  final int? userId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  ConsumerState<RepaymentList> createState() => _RepaymentListState();
}

class _RepaymentListState extends ConsumerState<RepaymentList> {
  late final PagingController<int, Repay> _pagingController;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Repay>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(voucherProvider.notifier)
          .getRepayment(
            page: pageKey,
            limit: limit,
            userId: widget.userId,
            startDate: widget.startDate,
            endDate: widget.endDate,
          ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  void _delete(Repay repayment, bool isDark) {
    showDeleteDialog(
      context,
      title: RepayLocaleScreen.repayDeleteConfirm.getString(context),
      isDark: isDark,
      submit: () async {
        await ref
            .read(voucherProvider.notifier)
            .deleteRepayment(repayment.id)
            .then((data) {
              if (data) {
                ShowToast(
                  context,
                  description: Text(
                    RepayLocaleScreen.repayDeleteSuccess.getString(context),
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
                  GeneralScreenLocale.somethingWentWrong.getString(context),
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

    final crossAxisCount = Responsive.isDesktop(context)
        ? 3
        : Responsive.isTablet(context)
        ? 2
        : 1;

    final mainAxisExtent = Responsive.isDesktop(context)
        ? 400.0
        : Responsive.isTablet(context)
        ? 380.0
        : 380.0;

    return RefreshIndicator(
      onRefresh: () async {
        _pagingController.refresh();
      },
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => PagedGridView<int, Repay>(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          state: state,
          fetchNextPage: fetchNextPage,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: mainAxisExtent,
          ),
          builderDelegate: PagedChildBuilderDelegate<Repay>(
            itemBuilder: (context, repayment, index) {
              return RepaymentCard(
                repayment: repayment,
                textColor: textColor,
                subColor: subColor,
                // onDelete:
                //     (user != null &&
                //         (isAdmin(user.role) || isManager(user.role)))
                //     ? () => _delete(repayment, isDark)
                //     : null,
              );
            },

            firstPageProgressIndicatorBuilder: (_) => LoadingWidget(),
            newPageProgressIndicatorBuilder: (_) => LoadingWidget(),
            noItemsFoundIndicatorBuilder: (_) =>
                NoItemFoundWidget(subColor: subColor),
          ),
        ),
      ),
    );
  }
}
