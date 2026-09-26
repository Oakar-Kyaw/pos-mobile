import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/component/delete-dialog.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/features/debt-voucher/presentation/widget/debt-repay-voucher-component.dart';
import 'package:pos/features/voucher/data/model/voucher-detail.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/responsive.dart';
import 'package:pos/utils/shad-toaster.dart';

class DebtListTile extends ConsumerStatefulWidget {
  const DebtListTile({super.key, this.userId, this.startDate, this.endDate});

  final int? userId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  ConsumerState<DebtListTile> createState() => _DebtListTileState();
}

class _DebtListTileState extends ConsumerState<DebtListTile> {
  late final PagingController<int, VoucherDetailModel> _pagingController;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, VoucherDetailModel>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(voucherProvider.notifier)
          .getVouchers(
            page: pageKey,
            limit: limit,
            existDebt: true,
            userId: widget.userId,
            startDate: widget.startDate,
            endDate: widget.endDate,
          ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  BoxDecoration getContainerBoxDecoration(bool isDark, Color dividerColor) {
    return BoxDecoration(
      color: isDark ? kSurfaceDark : kSurfaceLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: dividerColor, width: 0.5),
    );
  }

  void _delete(VoucherDetailModel voucher, bool isDark) {
    showDeleteDialog(
      context,
      title: VoucherScreenLocale.deleteVoucher.getString(context),
      isDark: isDark,
      submit: () async {
        await ref
            .read(voucherProvider.notifier)
            .deleteVoucher(voucher.id)
            .then((data) {
              if (data) {
                ShowToast(
                  context,
                  description: Text(
                    VoucherScreenLocale.deletedSuccess.getString(context),
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
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE5E7EB);
    final rowHoverColor = isDark
        ? kPrimary.withOpacity(0.06)
        : kPrimary.withOpacity(0.04);
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
        ? 350.0
        : Responsive.isTablet(context)
        ? 320.0
        : 320.0;

    return RefreshIndicator(
      onRefresh: () async {
        _pagingController.refresh();
      },
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) =>
            PagedGridView<int, VoucherDetailModel>(
              padding: const EdgeInsets.all(16),
              state: state,
              fetchNextPage: fetchNextPage,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: mainAxisExtent,
              ),
              builderDelegate: PagedChildBuilderDelegate<VoucherDetailModel>(
                itemBuilder: (context, voucher, index) {
                  final containerDecoration = getContainerBoxDecoration(
                    isDark,
                    dividerColor,
                  );
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    splashColor: kPrimary.withOpacity(0.08),
                    highlightColor: rowHoverColor,
                    child: Container(
                      // padding: const EdgeInsets.symmetric(
                      //   horizontal: 16,
                      //   vertical: 8,
                      // ),
                      decoration: containerDecoration,
                      child: DebtAndRepayVoucherListComponent(
                        textColor: textColor,
                        subColor: subColor,
                        voucher: voucher,
                        pagingController: _pagingController,
                        onDelete: (user != null && (isAdmin(user.role)))
                            ? () => _delete(voucher, isDark)
                            : null,
                      ),
                    ),
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
