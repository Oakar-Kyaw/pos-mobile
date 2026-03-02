import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/refund.api.dart';
import 'package:pos/component/table-cell.dart';
import 'package:pos/component/table-header.dart';
import 'package:pos/localization/refund-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/refund.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:pos/utils/responsive.dart';
import 'package:pos/utils/table-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RefundTable extends ConsumerStatefulWidget {
  const RefundTable({super.key});

  @override
  ConsumerState<RefundTable> createState() => _RefundTableState();
}

class _RefundTableState extends ConsumerState<RefundTable> {
  late final PagingController<int, Refund> _pagingController;

  final int limit = 20;

  @override
  void initState() {
    super.initState();

    _pagingController = PagingController<int, Refund>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(refundProvider.notifier)
          .fetchRefunds(page: pageKey, limit: limit),
    );
  }

  List<Widget> getTableRole(
    Refund refund,
    int index,
    Color textColor,
    Color subColor,
  ) {
    return [
      // buildTableCell("${index + 1}", subColor),
      buildTableCell(
        refund.voucher?.voucherCode ?? '-',
        textColor,
        highlight: true,
      ),
      buildTableCell(
        DateFormat('yyyy-MM-dd').format(refund.createdAt),
        subColor,
      ),
      buildTableCell(formatAmount(refund.amount), textColor),
      buildTableCell(refund.reason ?? '-', textColor),
    ];
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    //final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE5E7EB);
    final rowHoverColor = isDark
        ? kPrimary.withOpacity(0.06)
        : kPrimary.withOpacity(0.04);

    final tableTheme = TableThemeConfiguration(
      isDark: isDark,
      surfaceColor: surfaceColor,
      kPrimary: kPrimary,
      kSecondary: kSecondary,
      dividerColor: dividerColor,
    );

    const columnWidths = {
      // 0: FlexColumnWidth(1),
      0: FlexColumnWidth(4),
      1: FlexColumnWidth(2),
      2: FlexColumnWidth(2),
      3: FlexColumnWidth(3),
    };

    final tableHeaderLabelsOfPhone = [
      VoucherScreenLocale.voucherCode.getString(context),
      RefundLocale.refundDate.getString(context),
      RefundLocale.refundAmount.getString(context),
      RefundLocale.refundReason.getString(context),
    ];

    final tableHeaderLabelsOfTablet = [
      VoucherScreenLocale.voucherCode.getString(context),
      RefundLocale.refundDate.getString(context),
      RefundLocale.refundAmount.getString(context),
      RefundLocale.refundReason.getString(context),
    ];

    final tableHeaderLabels = Responsive.isMobile(context)
        ? tableHeaderLabelsOfPhone
        : tableHeaderLabelsOfTablet;

    return Container(
      height: 500,
      padding: const EdgeInsets.all(5),
      decoration: tableTheme.getTableContainerDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            decoration: tableTheme.getTableHeaderDecoration(),
            child: Table(
              columnWidths: columnWidths,
              children: [
                TableRow(
                  children: List.generate(
                    tableHeaderLabels.length,
                    (index) => buildTableHeader(
                      tableHeaderLabels[index],
                      context,
                      textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PagingListener(
              controller: _pagingController,
              builder: (context, state, fetchNextPage) =>
                  PagedListView<int, Refund>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate<Refund>(
                      itemBuilder: (context, refund, index) {
                        final isEven = index % 2 == 0;
                        return InkWell(
                          splashColor: kPrimary.withOpacity(0.08),
                          highlightColor: rowHoverColor,
                          child: Container(
                            decoration: tableTheme.getTableRowDecoration(
                              isEven,
                            ),
                            child: Table(
                              columnWidths: columnWidths,
                              children: [
                                TableRow(
                                  children: getTableRole(
                                    refund,
                                    index,
                                    textColor,
                                    subColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      firstPageProgressIndicatorBuilder: (_) => Center(
                        child: CircularProgressIndicator(color: kPrimary),
                      ),
                      newPageProgressIndicatorBuilder: (_) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(color: kPrimary),
                        ),
                      ),
                      noItemsFoundIndicatorBuilder: (_) => Center(
                        child: Text(
                          RefundLocale.refundNoItems.getString(context),
                          style: TextStyle(color: subColor, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
