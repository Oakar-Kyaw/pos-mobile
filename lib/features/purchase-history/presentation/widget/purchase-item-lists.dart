import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/delete-dialog.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/features/purchase-history/data/model/purchase.dart';
import 'package:pos/features/purchase-history/presentation/provider/purchase.api.dart';
import 'package:pos/features/purchase-history/presentation/widget/purchase-card.dart';
import 'package:pos/localization/inventory-management-local.dart';
import 'package:pos/models/inventory-management.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';

class PurchaseItemLists extends ConsumerStatefulWidget {
  const PurchaseItemLists({super.key, this.selectedData});

  final SelectedData? selectedData;

  @override
  ConsumerState<PurchaseItemLists> createState() => _PurchaseitemListState();
}

class _PurchaseitemListState extends ConsumerState<PurchaseItemLists> {
  late final PagingController<int, Purchase> _pagingController;

  final int limit = 1;

  int? _supplierId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    _supplierId = widget.selectedData?.supplierId;
    _startDate = widget.selectedData?.startDate;
    _endDate = widget.selectedData?.endDate;

    _pagingController = PagingController<int, Purchase>(
      getNextPageKey: (state) {
        return state.lastPageIsEmpty ? null : state.nextIntPageKey;
      },
      fetchPage: _fetchPage,
    );

    ref.listenManual<SelectedData?>(selectedDataStateProvider, (
      previous,
      next,
    ) {
      if (!mounted) {
        return;
      }

      final supplierChanged = previous?.supplierId != next?.supplierId;

      final startDateChanged = previous?.startDate != next?.startDate;

      final endDateChanged = previous?.endDate != next?.endDate;

      if (!supplierChanged && !startDateChanged && !endDateChanged) {
        return;
      }

      _supplierId = next?.supplierId;
      _startDate = next?.startDate;
      _endDate = next?.endDate;

      debugPrint(
        'Purchase filter changed: '
        'supplier=$_supplierId '
        'start=$_startDate '
        'end=$_endDate',
      );
      if (supplierChanged) {
        _pagingController.refresh();
        return;
      }
      if ((startDateChanged || endDateChanged) && _endDate != null) {
        print("start $_startDate, $_endDate");
        _pagingController.refresh();
      }
    });
  }

  Future<List<Purchase>> _fetchPage(int pageKey) async {
    if (!mounted) {
      return [];
    }

    final purchaseNotifier = ref.read(purchaseProvider.notifier);

    return purchaseNotifier.getPurchaseLists(
      page: pageKey,
      limit: limit,
      supplierId: _supplierId,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
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

  void _delete(InventoryManagement inventory, bool isDark) {
    showDeleteDialog(
      context,
      title: InventoryManagementLocale.inventoryDeleteConfirm.getString(
        context,
      ),
      isDark: isDark,
      submit: () async {
        await ref
            .read(productProvider.notifier)
            .deleteInventoryManagement(inventory.id!)
            .then((data) {
              if (data) {
                ShowToast(
                  context,
                  description: Text(
                    InventoryManagementLocale.inventoryDeleteSuccess.getString(
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
                  InventoryManagementLocale.inventoryDeleteFail.getString(
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
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE5E7EB);
    final rowHoverColor = isDark
        ? kPrimary.withOpacity(0.06)
        : kPrimary.withOpacity(0.04);
    print("date is $_startDate $_endDate");

    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => PagedListView<int, Purchase>(
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<Purchase>(
          itemBuilder: (context, purchaseItem, index) {
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
                child: PurchaseCard(
                  purchase: purchaseItem,
                  textColor: textColor,
                  subColor: subColor,
                  onEdit: () => context.pushNamed(
                    AppRoute.purchaseEdit,
                    extra: purchaseItem,
                  ),
                  onDetail: () => context.pushNamed(
                    AppRoute.purchaseDetail,
                    extra: purchaseItem,
                  ),
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
