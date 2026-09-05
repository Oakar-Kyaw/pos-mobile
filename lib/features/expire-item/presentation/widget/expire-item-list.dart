import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/core/utils/confirm-dialog.dart';
import 'package:pos/core/widgets/expire-damage-component.dart';
import 'package:pos/localization/inventory-management-local.dart';
import 'package:pos/models/inventory-management.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';

class ExpireDamageLists extends ConsumerStatefulWidget {
  final PagingController<int, InventoryManagement> pagingController;
  const ExpireDamageLists({
    super.key,
    this.selectedData,
    required this.pagingController,
  });

  final SelectedData? selectedData;

  @override
  ConsumerState<ExpireDamageLists> createState() => _ExpireDamageListsState();
}

class _ExpireDamageListsState extends ConsumerState<ExpireDamageLists> {
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

  Future<void> _onDelete(int id) async {
    try {
      final confirmed = await showConfirmDialog(
        context,
        title: InventoryManagementLocale.inventoryConfirmDelete.getString(
          context,
        ),
        content: InventoryManagementLocale.inventoryDeleteConfirm.getString(
          context,
        ),
        confirmLabel: InventoryManagementLocale.inventoryDelete.getString(
          context,
        ),
        cancelLabel: InventoryManagementLocale.inventoryCancel.getString(
          context,
        ),
      );
      if (confirmed != true) return;

      debugPrint("Deleting inventory: $id");

      final success = await ref
          .read(productProvider.notifier)
          .deleteInventoryManagement(id);

      if (!context.mounted) return;

      if (success) {
        widget.pagingController.refresh();
        ShowToast(
          context,
          description: Text(
            InventoryManagementLocale.inventoryDeleteSuccess.getString(context),
            style: TextStyle(color: kGreen),
          ),
          borderColor: kGreen,
        );
      }
    } catch (e, stackTrace) {
      debugPrint("Error deleting inventory: $e");
      debugPrintStack(stackTrace: stackTrace);

      if (!context.mounted) return;

      ShowToast(
        context,
        description: Text(e.toString(), style: TextStyle(color: kRed)),
        borderColor: kRed,
        isError: true,
      );
    }
  }

  void _onDetail(InventoryManagement inven) {
    context.pushNamed(AppRoute.inventoryDetail, extra: inven);
  }

  void _onEdit(InventoryManagement inven) async {
    final result = await context.pushNamed(
      AppRoute.inventoryEditItem,
      //for damage and expire type is Damage
      extra: {'type': 'Damage', 'inv': inven},
    );

    if (result == true && mounted) {
      widget.pagingController.refresh();
    }
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
      widget.pagingController.refresh();
    });

    return RefreshIndicator(
      onRefresh: () async => widget.pagingController.refresh(),
      child: PagingListener(
        controller: widget.pagingController,
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
                        pagingController: widget.pagingController,
                        textColor: textColor,
                        subColor: subColor,
                        inventory: expireItem,
                        onEdit: () => (user != null && isAdmin(user.role))
                            ? _onEdit(expireItem)
                            : null,
                        onDetail: () => _onDetail(expireItem),
                        onDelete:
                            (user != null &&
                                (isAdmin(user.role) || isManager(user.role)))
                            ? () => _onDelete(expireItem.id!)
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
