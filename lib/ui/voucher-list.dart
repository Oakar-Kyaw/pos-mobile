import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/component/delete-dialog.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/component/voucher-list-component.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/shad-toaster.dart';

class VoucherList extends ConsumerStatefulWidget {
  final int? userId;
  final DateTime? startDate;
  final DateTime? endDate;
  const VoucherList({super.key, this.userId, this.startDate, this.endDate});

  @override
  ConsumerState<VoucherList> createState() => _VoucherListState();
}

class _VoucherListState extends ConsumerState<VoucherList> {
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

  void _delete(VoucherDetailModel voucher, bool isDark) {
    showDeleteDialog(
      context,
      title: VoucherScreenLocale.deleteVoucher.getString(context),
      isDark: isDark,
      submit: () async {
        //print("delete");
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

  Widget getVoucherComponentByRole(
    String role,
    Color textColor,
    Color subColor,
    bool isDark,
    VoucherDetailModel voucher,
  ) {
    return (isAdmin(role) || isManager(role))
        ? VoucherComponent(
            textColor: textColor,
            subColor: subColor,
            voucher: voucher,
            pagingController: _pagingController,
            onDelete: () => _delete(voucher, isDark),
          )
        : VoucherComponent(
            textColor: textColor,
            subColor: subColor,
            voucher: voucher,
            pagingController: _pagingController,
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

    // Listen to selected user changes and refresh paging controller
    ref.listen<SelectedData?>(selectedDataStateProvider, (prev, next) {
      _pagingController.refresh();
    });

    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) =>
          PagedListView<int, VoucherDetailModel>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<VoucherDetailModel>(
              itemBuilder: (context, voucher, index) {
                final isEven = index % 2 == 0;
                BoxDecoration containerDecoration = isEven
                    ? getContainerBoxDecorationByEven(dividerColor)
                    : getContainerBoxDecorationByOdd(isDark, dividerColor);
                return InkWell(
                  splashColor: kPrimary.withOpacity(0.08),
                  highlightColor: rowHoverColor,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: containerDecoration,
                    child: getVoucherComponentByRole(
                      user!.role,
                      textColor,
                      subColor,
                      isDark,
                      voucher,
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
    );
  }
}
