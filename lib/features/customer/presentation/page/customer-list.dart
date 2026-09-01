import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/features/customer/data/model/customer-model.dart';
import 'package:pos/features/customer/presentation/page/customer-card.dart';
import 'package:pos/features/customer/presentation/provider/customer-provider.dart';
import 'package:pos/localization/customer-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';

class CustomerLists extends ConsumerStatefulWidget {
  const CustomerLists({super.key});

  @override
  ConsumerState<CustomerLists> createState() => _CustomerListsState();
}

class _CustomerListsState extends ConsumerState<CustomerLists> {
  late final PagingController<int, Customer> _pagingController;

  final int limit = 20;

  @override
  void initState() {
    super.initState();

    _pagingController = PagingController<int, Customer>(
      getNextPageKey: (state) {
        return state.lastPageIsEmpty ? null : state.nextIntPageKey;
      },
      fetchPage: _fetchPage,
    );
  }

  Future<List<Customer>> _fetchPage(int pageKey) async {
    if (!mounted) {
      return [];
    }

    final customerNotifier = ref.read(customerProvider.notifier);

    return customerNotifier.getCustomerLists(page: pageKey, limit: limit);
  }

  Future<void> _onDelete(int id) async {
    if (!mounted) return;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(CustomerLocale.customerDelete.getString(context)),
            content: Text(
              CustomerLocale.customerDeleteConfirm.getString(context),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  CustomerLocale.customerDelete.getString(context),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      final success = await ref
          .read(customerProvider.notifier)
          .deleteCustomer(id);

      if (!mounted) return;

      if (success) {
        ShowToast(
          context,
          description: Text(
            CustomerLocale.customerDeleteSuccess.getString(context),
            style: TextStyle(color: kGreen),
          ),
          borderColor: kGreen,
        );

        _pagingController.refresh();
      }
    } catch (e, stackTrace) {
      debugPrint('Error deleting customer: $e');

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

  BoxDecoration _getContainerDecoration(
    bool isDark,
    Color dividerColor,
    int index,
  ) {
    final isEven = index % 2 == 0;

    return BoxDecoration(
      color: isEven
          ? Colors.transparent
          : (isDark
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

    return RefreshIndicator(
      onRefresh: () async {
        _pagingController.refresh();
      },
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) {
          return PagedListView<int, Customer>(
            state: state,
            fetchNextPage: fetchNextPage,
            padding: const EdgeInsets.symmetric(vertical: 6),
            builderDelegate: PagedChildBuilderDelegate<Customer>(
              itemBuilder: (context, customer, index) {
                return InkWell(
                  splashColor: kPrimary.withOpacity(0.08),
                  highlightColor: rowHoverColor,
                  child: Container(
                    decoration: _getContainerDecoration(
                      isDark,
                      dividerColor,
                      index,
                    ),
                    child: CustomerCard(
                      key: ValueKey(customer.id),
                      customer: customer,
                      textColor: textColor,
                      subColor: subColor,

                      onDelete: () => _onDelete(customer.id),
                    ),
                  ),
                );
              },

              firstPageProgressIndicatorBuilder: (_) => const LoadingWidget(),

              newPageProgressIndicatorBuilder: (_) => const LoadingWidget(),

              noItemsFoundIndicatorBuilder: (_) =>
                  NoItemFoundWidget(subColor: subColor),
            ),
          );
        },
      ),
    );
  }
}
