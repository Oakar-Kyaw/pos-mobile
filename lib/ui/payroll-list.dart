import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/payroll.api.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/component/payroll-card.dart';
import 'package:pos/models/payroll.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/route-constant.dart';

class PayrollList extends ConsumerStatefulWidget {
  const PayrollList({super.key, this.userId, this.fromDate, this.toDate});

  final int? userId;
  final DateTime? fromDate;
  final DateTime? toDate;

  @override
  ConsumerState<PayrollList> createState() => PayrollListState();
}

class PayrollListState extends ConsumerState<PayrollList> {
  late final PagingController<int, PayrollRecord> _pagingController;
  final int limit = 10;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, PayrollRecord>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(payrollProvider.notifier)
          .getAllPayroll(page: pageKey, limit: limit, userId: widget.userId)
          .then((items) => _applyDateFilter(items)),
    );
  }

  List<PayrollRecord> _applyDateFilter(List<PayrollRecord> items) {
    if (widget.fromDate == null && widget.toDate == null) return items;

    DateTime? from = widget.fromDate;
    DateTime? to = widget.toDate;
    if (from != null && to != null && from.isAfter(to)) {
      final temp = from;
      from = to;
      to = temp;
    }

    return items.where((p) {
      final createdAt = p.createdAt;
      final afterFrom = from == null || !createdAt.isBefore(from);
      final beforeTo = to == null || !createdAt.isAfter(to);
      return afterFrom && beforeTo;
    }).toList();
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  @override
  void didUpdateWidget(covariant PayrollList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.fromDate != widget.fromDate ||
        oldWidget.toDate != widget.toDate) {
      _pagingController.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) =>
          PagedListView<int, PayrollRecord>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<PayrollRecord>(
              itemBuilder: (context, payroll, index) {
                return InkWell(
                  onTap: () => context.pushNamed(
                    AppRoute.payrollPayslip,
                    pathParameters: {'id': payroll.id.toString()},
                  ),
                  splashColor: kPrimary.withOpacity(0.08),
                  child: PayrollCard(
                    payroll: payroll,
                    textColor: textColor,
                    subColor: subColor,
                    isDark: isDark,
                  ),
                );
              },
              firstPageProgressIndicatorBuilder: (_) => const LoadingWidget(),
              newPageProgressIndicatorBuilder: (_) => const LoadingWidget(),
              noItemsFoundIndicatorBuilder: (_) =>
                  NoItemFoundWidget(subColor: subColor),
            ),
          ),
    );
  }
}
