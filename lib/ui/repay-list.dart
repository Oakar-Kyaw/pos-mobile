import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/component/repay-card.dart';
import 'package:pos/models/repayment.dart';
import 'package:pos/utils/app-theme.dart';

class RepaymentList extends ConsumerStatefulWidget {
  const RepaymentList({super.key});

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
          .getRepayment(page: pageKey, limit: limit),
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

    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => PagedListView<int, Repay>(
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<Repay>(
          itemBuilder: (context, repayment, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: RepaymentCard(
                repayment: repayment,
                textColor: textColor,
                subColor: subColor,
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
