import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VoucherTablePage extends ConsumerStatefulWidget {
  const VoucherTablePage({super.key});

  @override
  ConsumerState<VoucherTablePage> createState() => _VoucherTablePageState();
}

class _VoucherTablePageState extends ConsumerState<VoucherTablePage> {
  final int limit = 20;

  late final PagingController<int, VoucherDetailModel> _pagingController =
      PagingController<int, VoucherDetailModel>(
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => ref
            .read(voucherProvider.notifier)
            .getVouchersByUserId(page: pageKey, limit: limit),
      );

  String searchQuery = "";

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  String formatAmount(double value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);

  Widget _buildTableHeader(
    String text,
    BuildContext context,
    Color textColor, {
    bool alignRight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: FontSizeConfig.body(context),
            color: textColor,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text,
    Color textColor, {
    bool alignRight = false,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
          style: TextStyle(
            color: highlight ? kPrimary : textColor,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE5E7EB);
    final rowHoverColor = isDark
        ? kPrimary.withOpacity(0.06)
        : kPrimary.withOpacity(0.04);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: DrawerScreenLocale.drawerVoucher.getString(context),
      ),
      body: Column(
        children: [
          // ── Description banner ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(isDark ? 0.15 : 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: kPrimary.withOpacity(isDark ? 0.3 : 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.ticket,
                      color: kPrimary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      VoucherScreenLocale.viewAllVouchers.getString(context),
                      style: TextStyle(
                        fontSize: FontSizeConfig.body(context),
                        color: subColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Section label ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, kSecondary],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  DrawerScreenLocale.drawerVoucher.getString(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Table card ───────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? kPrimary.withOpacity(0.1)
                          : Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // ── Table header ──────────────────
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kPrimary.withOpacity(isDark ? 0.25 : 0.08),
                            kSecondary.withOpacity(isDark ? 0.15 : 0.04),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        border: Border(
                          bottom: BorderSide(color: dividerColor, width: 1),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(4),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            children: [
                              _buildTableHeader(
                                VoucherScreenLocale.no.getString(context),
                                context,
                                textColor,
                              ),
                              _buildTableHeader(
                                VoucherScreenLocale.voucherCode.getString(
                                  context,
                                ),
                                context,
                                textColor,
                              ),
                              _buildTableHeader(
                                VoucherScreenLocale.date.getString(context),
                                context,
                                textColor,
                              ),
                              _buildTableHeader(
                                VoucherScreenLocale.total.getString(context),
                                context,
                                textColor,
                                alignRight: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Paged rows ────────────────────
                    Expanded(
                      child: PagingListener(
                        controller: _pagingController,
                        builder: (context, state, fetchNextPage) =>
                            PagedListView<int, VoucherDetailModel>(
                              state: state,
                              fetchNextPage: fetchNextPage,
                              builderDelegate:
                                  PagedChildBuilderDelegate<VoucherDetailModel>(
                                    itemBuilder: (context, voucher, index) {
                                      final isEven = index % 2 == 0;
                                      return InkWell(
                                        onTap: () => context.pushNamed(
                                          AppRoute.receipt,
                                          extra: voucher.id,
                                        ),
                                        splashColor: kPrimary.withOpacity(0.08),
                                        highlightColor: rowHoverColor,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isEven
                                                ? Colors.transparent
                                                : (isDark
                                                      ? Colors.white
                                                            .withOpacity(0.02)
                                                      : Colors.black
                                                            .withOpacity(0.01)),
                                            border: Border(
                                              bottom: BorderSide(
                                                color: dividerColor,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          child: Table(
                                            columnWidths: const {
                                              0: FlexColumnWidth(1),
                                              1: FlexColumnWidth(4),
                                              2: FlexColumnWidth(2),
                                              3: FlexColumnWidth(2),
                                            },
                                            children: [
                                              TableRow(
                                                children: [
                                                  _buildTableCell(
                                                    "${index + 1}",
                                                    subColor,
                                                  ),
                                                  _buildTableCell(
                                                    voucher.voucherCode ?? "-",
                                                    textColor,
                                                    highlight: true,
                                                  ),
                                                  _buildTableCell(
                                                    voucher.createdAt != null
                                                        ? DateFormat(
                                                            'yyyy-MM-dd',
                                                          ).format(
                                                            voucher.createdAt!,
                                                          )
                                                        : "-",
                                                    subColor,
                                                  ),
                                                  _buildTableCell(
                                                    formatAmount(voucher.total),
                                                    textColor,
                                                    alignRight: true,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },

                                    firstPageProgressIndicatorBuilder: (_) =>
                                        Center(
                                          child: CircularProgressIndicator(
                                            color: kPrimary,
                                          ),
                                        ),
                                    newPageProgressIndicatorBuilder: (_) =>
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: kPrimary,
                                            ),
                                          ),
                                        ),
                                    noItemsFoundIndicatorBuilder: (_) => Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: kPrimary.withOpacity(0.08),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              LucideIcons.ticket,
                                              color: kPrimary,
                                              size: 32,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            VoucherScreenLocale.noItems
                                                .getString(context),
                                            style: TextStyle(
                                              color: subColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
