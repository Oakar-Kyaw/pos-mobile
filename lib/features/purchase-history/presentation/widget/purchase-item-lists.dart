import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/core/utils/confirm-dialog.dart';
import 'package:pos/features/purchase-history/data/model/purchase.dart';
import 'package:pos/features/purchase-history/presentation/provider/purchase.api.dart';
import 'package:pos/features/purchase-history/presentation/widget/purchase-card.dart';
import 'package:pos/localization/purchase-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/responsive.dart';
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

  Future<void> _onDelete(int index) async {
    if (!mounted) return;
    try {
      final confirmed = await showConfirmDialog(
        context,
        title: PurchaseLocale.purchaseDelete.getString(context),
        content: PurchaseLocale.purchaseDeleteConfirm.getString(context),
        confirmLabel: PurchaseLocale.purchaseDelete.getString(context),
        cancelLabel: PurchaseLocale.purchaseCancel.getString(context),
      );
      if (confirmed != true) return;

      debugPrint("Deleting purchase: $index");

      final success = await ref
          .read(purchaseProvider.notifier)
          .deletePurchase(index);

      if (success) {
        ShowToast(
          context,
          description: Text(
            PurchaseLocale.purchaseDeleteSuccess.getString(context),
            style: TextStyle(color: kGreen),
          ),
          borderColor: kGreen,
        );
        _pagingController.refresh();
      }
    } catch (e, stackTrace) {
      debugPrint("Error deleting purchase: $e");

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ShowToast(
        context,
        description: Text(e.toString(), style: TextStyle(color: kRed)),
        borderColor: kRed,
        isError: true,
      );
    }
  }

  Future<void> _onSuccess(int index) async {
    if (!mounted) return;
    try {
      debugPrint("Success purchase: $index");

      final success = await ref
          .read(purchaseProvider.notifier)
          .updateSucess(index);

      if (success) {
        ShowToast(
          context,
          description: Text(
            PurchaseLocale.purchaseDeliveredSuccessfully.getString(context),
            style: TextStyle(color: kGreen),
          ),
          borderColor: kGreen,
        );
        _pagingController.refresh();
      }
    } catch (e, stackTrace) {
      debugPrint("Error delivering purchase: $e");

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ShowToast(
        context,
        description: Text(e.toString(), style: TextStyle(color: kRed)),
        borderColor: kRed,
        isError: true,
      );
    }
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

    final crossAxisCount =
        (Responsive.isDesktop(context) || Responsive.isTablet(context)) ? 2 : 1;

    final mainAxisExtent = crossAxisCount == 2 ? 350.0 : 350.0;

    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => PagedGridView<int, Purchase>(
        state: state,
        fetchNextPage: fetchNextPage,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: mainAxisExtent,
        ),
        builderDelegate: PagedChildBuilderDelegate<Purchase>(
          itemBuilder: (context, purchaseItem, index) {
            final containerDecoration = getContainerBoxDecoration(
              isDark,
              dividerColor,
            );
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: kPrimary.withOpacity(0.08),
              highlightColor: rowHoverColor,
              child: Container(
                decoration: containerDecoration,
                child: PurchaseCard(
                  onDelete: () => _onDelete(purchaseItem.id),
                  purchase: purchaseItem,
                  textColor: textColor,
                  subColor: subColor,

                  onSuccess: () => _onSuccess(purchaseItem.id),

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
