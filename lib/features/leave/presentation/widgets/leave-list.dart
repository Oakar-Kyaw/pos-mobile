import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/features/leave/domain/entites/leave.dart';
import 'package:pos/features/leave/presentation/riverpod/leave-provider.dart';
import 'package:pos/features/leave/presentation/widgets/leave-card.dart';
import 'package:pos/utils/app-theme.dart';

class Leavelist extends ConsumerStatefulWidget {
  const Leavelist({super.key, this.userId, this.startDate, this.endDate});

  final int? userId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  ConsumerState<Leavelist> createState() => _LeavelistState();
}

class _LeavelistState extends ConsumerState<Leavelist> {
  late final PagingController<int, Leave> _pagingController;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Leave>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(leaveProvider.notifier)
          .fetchLeaves(
            page: pageKey,
            limit: limit,
            // startDate: widget.startDate,
            // endDate: widget.endDate,
          ),
    );
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

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => PagedListView<int, Leave>(
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<Leave>(
          itemBuilder: (context, leave, index) {
            return LeaveCard(
              leave: leave,
              textColor: textColor,
              subColor: subColor,
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
