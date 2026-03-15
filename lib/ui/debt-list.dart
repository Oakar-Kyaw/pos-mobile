import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/component/debt-repay-voucher-component.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';

class DebtListTile extends ConsumerStatefulWidget {
  const DebtListTile({super.key});

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
          .getVouchers(page: pageKey, limit: limit, existDebt: true),
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
                    child: DebtAndRepayVoucherListComponent(
                      textColor: textColor,
                      subColor: subColor,
                      voucher: voucher,
                      pagingController: _pagingController,
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
