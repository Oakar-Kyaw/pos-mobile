import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';

import 'package:pos/features/supplier/data/model/supplier.dart';
import 'package:pos/features/supplier/presentation/page/supplier-card.dart';
import 'package:pos/features/supplier/presentation/provider/supplier-provider.dart';

import 'package:pos/localization/supplier-local.dart';

import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/shad-toaster.dart';

class SupplierItemLists extends ConsumerStatefulWidget {
  const SupplierItemLists({super.key});

  @override
  ConsumerState<SupplierItemLists> createState() => _SupplierItemListsState();
}

class _SupplierItemListsState extends ConsumerState<SupplierItemLists> {
  late final PagingController<int, Supplier> _pagingController;

  final int limit = 10;

  @override
  void initState() {
    super.initState();

    _pagingController = PagingController<int, Supplier>(
      getNextPageKey: (state) {
        return state.lastPageIsEmpty ? null : state.nextIntPageKey;
      },
      fetchPage: _fetchPage,
    );
  }

  // ============================================================
  // FETCH SUPPLIERS
  // ============================================================

  Future<List<Supplier>> _fetchPage(int pageKey) async {
    if (!mounted) {
      return [];
    }

    final supplierNotifier = ref.read(supplierProvider.notifier);

    return supplierNotifier.getSupplierLists(page: pageKey, limit: limit);
  }

  // ============================================================
  // DELETE SUPPLIER
  // ============================================================

  Future<void> _onDelete(int id) async {
    if (!mounted) return;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(SupplierLocale.supplierDelete.getString(dialogContext)),
            content: Text(
              SupplierLocale.supplierDeleteConfirm.getString(dialogContext),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: Text(
                  SupplierLocale.supplierCancel.getString(dialogContext),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: Text(
                  SupplierLocale.supplierDelete.getString(dialogContext),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        return;
      }

      debugPrint("Deleting supplier: $id");

      final success = await ref
          .read(supplierProvider.notifier)
          .deleteSupplier(id);

      if (!mounted) return;

      if (success) {
        ShowToast(
          context,
          description: Text(
            SupplierLocale.supplierDeleteSuccess.getString(context),
            style: const TextStyle(color: kGreen),
          ),
          borderColor: kGreen,
        );

        // Refresh the pagination list
        _pagingController.refresh();
      }
    } catch (e, stackTrace) {
      debugPrint("Error deleting supplier: $e");

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ShowToast(
        context,
        description: Text(e.toString(), style: const TextStyle(color: kRed)),
        borderColor: kRed,
        isError: true,
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _pagingController.dispose();

    super.dispose();
  }

  // ============================================================
  // EVEN ROW
  // ============================================================

  BoxDecoration getContainerBoxDecorationByEven(Color dividerColor) {
    return BoxDecoration(
      color: Colors.transparent,
      border: Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
    );
  }

  // ============================================================
  // ODD ROW
  // ============================================================

  BoxDecoration getContainerBoxDecorationByOdd(
    bool isDark,
    Color dividerColor,
  ) {
    return BoxDecoration(
      color: isDark
          ? Colors.white.withOpacity(0.02)
          : Colors.black.withOpacity(0.01),
      border: Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

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

    return RefreshIndicator(
      onRefresh: () async {
        _pagingController.refresh();
      },
      child: PagingListener(
        controller: _pagingController,

        builder: (context, state, fetchNextPage) {
          return PagedListView<int, Supplier>(
            state: state,

            fetchNextPage: fetchNextPage,

            builderDelegate: PagedChildBuilderDelegate<Supplier>(
              // ==================================================
              // ITEM
              // ==================================================
              itemBuilder: (context, supplier, index) {
                final isEven = index % 2 == 0;

                final containerDecoration = isEven
                    ? getContainerBoxDecorationByEven(dividerColor)
                    : getContainerBoxDecorationByOdd(isDark, dividerColor);

                return InkWell(
                  splashColor: kPrimary.withOpacity(0.08),

                  highlightColor: rowHoverColor,

                  child: Container(
                    decoration: containerDecoration,

                    child: SupplierCard(
                      supplier: supplier,

                      textColor: textColor,

                      subColor: subColor,

                      // DELETE
                      onDelete: () => _onDelete(supplier.id),

                      // EDIT
                      // onEdit: () {
                      //   context.pushNamed(AppRoute.supplierEdit, extra: supplier);
                      // },

                      // // DETAIL
                      // onDetail: () {
                      //   context.pushNamed(
                      //     AppRoute.supplierDetail,
                      //     extra: supplier,
                      //   );
                      // },
                    ),
                  ),
                );
              },

              // ==================================================
              // LOADING
              // ==================================================
              firstPageProgressIndicatorBuilder: (_) => LoadingWidget(),

              newPageProgressIndicatorBuilder: (_) => LoadingWidget(),

              // ==================================================
              // EMPTY
              // ==================================================
              noItemsFoundIndicatorBuilder: (_) =>
                  NoItemFoundWidget(subColor: subColor),
            ),
          );
        },
      ),
    );
  }
}
