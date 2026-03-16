import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/refund.api.dart';
import 'package:pos/component/delete-dialog.dart';
import 'package:pos/component/delete-icon.dart';
import 'package:pos/localization/refund-local.dart';
import 'package:pos/models/refund.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RefundCard extends ConsumerStatefulWidget {
  final SelectedData? selectedData;
  const RefundCard({super.key, this.selectedData});

  @override
  ConsumerState<RefundCard> createState() => _RefundCardState();
}

class _RefundCardState extends ConsumerState<RefundCard> {
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
          .fetchRefunds(
            page: pageKey,
            limit: limit,
            userId: widget.selectedData?.userId,
            startDate: widget.selectedData?.startDate,
            endDate: widget.selectedData?.endDate,
          ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
    _clearSelectedData();
  }

  void _clearSelectedData() {
    ref.read(selectedDataStateProvider.notifier).clear();
  }

  void _delete(Refund refund, bool isDark) {
    showDeleteDialog(
      context,
      title: RefundLocale.refundDeleteConfirm.getString(context),
      isDark: isDark,
      submit: () async {
        await ref
            .read(refundProvider.notifier)
            .deleteRefund(refund.id)
            .then((data) {
              if (data) {
                ShowToast(
                  context,
                  description: Text(
                    RefundLocale.refundDeleteSuccess.getString(context),
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
                  RefundLocale.refundDeleteFail.getString(context),
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

    ref.listen<SelectedData?>(selectedDataStateProvider, (prev, nex) {
      _pagingController.refresh();
    });

    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => PagedListView<int, Refund>(
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<Refund>(
          itemBuilder: (context, refund, index) {
            return _RefundCard(
              refund: refund,
              textColor: textColor,
              subColor: subColor,
              isDark: isDark,
              onDelete: () => _delete(refund, isDark),
            );
          },
          firstPageProgressIndicatorBuilder: (_) =>
              Center(child: CircularProgressIndicator(color: kPrimary)),
          newPageProgressIndicatorBuilder: (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(color: kPrimary)),
          ),
          noItemsFoundIndicatorBuilder: (_) => Center(
            child: Text(
              RefundLocale.refundNoItems.getString(context),
              style: TextStyle(color: subColor, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

class _RefundCard extends ConsumerWidget {
  const _RefundCard({
    required this.refund,
    required this.textColor,
    required this.subColor,
    required this.isDark,
    this.onDelete,
  });

  final Refund refund;
  final Color textColor;
  final Color subColor;
  final bool isDark;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateProvider);
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? kSurfaceDark : kSurfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.06),
        ),
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
      child: Stack(
        children: [
          RefundData(
            isDark: isDark,
            refund: refund,
            textColor: textColor,
            subColor: subColor,
          ),
          if (onDelete != null && (isAdmin(user!.role) || isManager(user.role)))
            DeleteIcon(onDelete: onDelete, top: 0),
        ],
      ),
    );
  }
}

class RefundData extends StatelessWidget {
  const RefundData({
    super.key,
    required this.isDark,
    required this.refund,
    required this.textColor,
    required this.subColor,
  });

  final bool isDark;
  final Refund refund;
  final Color textColor;
  final Color subColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RefundTitle(isDark: isDark, refund: refund, textColor: textColor),
        const SizedBox(height: 10),
        RefundDateRow(subColor: subColor, refund: refund, textColor: textColor),
        const SizedBox(height: 8),
        Text(
          RefundLocale.refundReason.getString(context),
          style: TextStyle(fontSize: 12, color: subColor),
        ),
        const SizedBox(height: 4),
        Text(
          refund.reason ?? '-',
          style: TextStyle(
            fontSize: FontSizeConfig.body(context),
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class RefundDateRow extends StatelessWidget {
  const RefundDateRow({
    super.key,
    required this.subColor,
    required this.refund,
    required this.textColor,
  });

  final Color subColor;
  final Refund refund;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(LucideIcons.calendar, size: 12, color: subColor),
        const SizedBox(width: 6),
        Text(
          DateFormat('yyyy-MM-dd').format(refund.createdAt),
          style: TextStyle(
            fontSize: FontSizeConfig.body(context),
            color: subColor,
          ),
        ),
        Spacer(),
        Text(
          formatAmount(refund.amount),
          style: TextStyle(
            fontSize: FontSizeConfig.title(context),
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class RefundTitle extends StatelessWidget {
  const RefundTitle({
    super.key,
    required this.isDark,
    required this.refund,
    required this.textColor,
  });

  final bool isDark;
  final Refund refund;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(LucideIcons.dollarSign, color: kPrimary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            refund.voucher?.voucherCode ?? '-',
            style: TextStyle(
              fontSize: FontSizeConfig.title(context),
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
