import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/features/product/presentation/widget/products-by-role.dart';
import 'package:pos/models/product.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';

class ProductLists extends ConsumerStatefulWidget {
  const ProductLists({super.key, this.searchQuery = ""});
  final String searchQuery;

  @override
  ConsumerState<ProductLists> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductLists> {
  late final PagingController<int, Product> _pagingController;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Product>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(productProvider.notifier)
          .getProductLists(
            pageKey.toString(),
            limit.toString(),
            search: widget.searchQuery,
          ),
    );
  }

  @override
  void didUpdateWidget(covariant ProductLists oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _pagingController.refresh();
    }
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

  // void _delete(VoucherDetailModel voucher, bool isDark) {
  //   showDeleteDialog(
  //     context,
  //     title: VoucherScreenLocale.deleteVoucher.getString(context),
  //     isDark: isDark,
  //     submit: () async {
  //       //print("delete");
  //       await ref
  //           .read(voucherProvider.notifier)
  //           .deleteVoucher(voucher.id)
  //           .then((data) {
  //             if (data) {
  //               ShowToast(
  //                 context,
  //                 description: Text(
  //                   VoucherScreenLocale.deletedSuccess.getString(context),
  //                 ),
  //               );
  //               context.pop();
  //               _pagingController.refresh();
  //             }
  //           })
  //           .catchError((err) {
  //             ShowToast(
  //               context,
  //               description: Text(
  //                 GeneralScreenLocale.somethingWentWrong.getString(context),
  //               ),
  //               isError: true,
  //             );
  //           });
  //     },
  //   );
  // }

  // Widget getVoucherComponentByRole(
  //   String role,
  //   Color textColor,
  //   Color subColor,
  //   bool isDark,
  //   VoucherDetailModel voucher,
  // ) {
  //   return (isAdmin(role) || isManager(role))
  //       ? VoucherComponent(
  //           textColor: textColor,
  //           subColor: subColor,
  //           voucher: voucher,
  //           pagingController: _pagingController,
  //           onDelete: () => _delete(voucher, isDark),
  //         )
  //       : VoucherComponent(
  //           textColor: textColor,
  //           subColor: subColor,
  //           voucher: voucher,
  //           pagingController: _pagingController,
  //         );
  // }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE5E7EB);
    final rowHoverColor = isDark
        ? kPrimary.withOpacity(0.06)
        : kPrimary.withOpacity(0.04);

    final user = ref.watch(userStateProvider);
    print("user is: ${user!.role}");

    // Listen to selected user changes and refresh paging controller
    // ref.listen<SelectedData?>(selectedDataStateProvider, (prev, next) {
    //   _pagingController.refresh();
    // });

    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => PagedListView<int, Product>(
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<Product>(
          itemBuilder: (context, product, index) {
            final isEven = index % 2 == 0;
            BoxDecoration containerDecoration = isEven
                ? getContainerBoxDecorationByEven(dividerColor)
                : getContainerBoxDecorationByOdd(isDark, dividerColor);
            return Material(
              type: MaterialType.transparency,
              child: InkWell(
                splashColor: kPrimary.withOpacity(0.08),
                highlightColor: rowHoverColor,
                child: (user.role == "ADMIN")
                    ?
                      //only see this by admin and manager role
                      ProductListByAdminAndManager(
                        key: ValueKey(product.id),
                        product: product,
                        containerDecoration: containerDecoration,
                      )
                    //only other role see this
                    : ProductListByPosAndSale(
                        product: product,
                        containerDecoration: containerDecoration,
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
