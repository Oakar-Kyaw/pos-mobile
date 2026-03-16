import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/expire-damage-component.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/models/inventory-management.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';

class RequestItemLists extends ConsumerStatefulWidget {
  const RequestItemLists({super.key, this.userId, this.startDate, this.endDate});

  final int? userId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  ConsumerState<RequestItemLists> createState() => _ExpireDamageListsState();
}

class _ExpireDamageListsState extends ConsumerState<RequestItemLists> {
  late final PagingController<int, InventoryManagement> _pagingController;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, InventoryManagement>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(productProvider.notifier)
          .getExpireDamageRequestList(
            page: pageKey,
            limit: limit,
            type: "REQUESTED",
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

    ref.listen<SelectedData?>(selectedDataStateProvider, (prev, next) {
      _pagingController.refresh();
    });

    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) =>
          PagedListView<int, InventoryManagement>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<InventoryManagement>(
              itemBuilder: (context, expireItem, index) {
                // print("Expire item 🥸 ${expireItem.totalAmount}");
                final isEven = index % 2 == 0;
                BoxDecoration containerDecoration = isEven
                    ? getContainerBoxDecorationByEven(dividerColor)
                    : getContainerBoxDecorationByOdd(isDark, dividerColor);
                return InkWell(
                  splashColor: kPrimary.withOpacity(0.08),
                  highlightColor: rowHoverColor,
                  child: Container(
                    // padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: containerDecoration,
                    child: ExpireDamageCard(
                      textColor: textColor,
                      subColor: subColor,
                      inventory: expireItem,
                      //pagingController: _pagingController,
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
