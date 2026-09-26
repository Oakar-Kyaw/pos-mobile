import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/user.api.dart';
import 'package:pos/component/employee-card.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/features/profile/data/model/user.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/responsive.dart';

class EmployeeList extends ConsumerStatefulWidget {
  const EmployeeList({super.key});

  @override
  ConsumerState<EmployeeList> createState() => _EmployeeListState();
}

class _EmployeeListState extends ConsumerState<EmployeeList> {
  late final PagingController<int, User> _pagingController;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, User>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(userProvider.notifier)
          .getAllUser(page: pageKey, limit: limit),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final rowHoverColor = isDark
        ? kPrimary.withOpacity(0.06)
        : kPrimary.withOpacity(0.04);

    final crossAxisCount =
        (Responsive.isDesktop(context) || Responsive.isTablet(context)) ? 2 : 1;

    final mainAxisExtent = crossAxisCount == 2 ? 350.0 : 300.0;

    return RefreshIndicator(
      onRefresh: () async {
        _pagingController.refresh();
      },
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => PagedGridView<int, User>(
          state: state,
          fetchNextPage: fetchNextPage,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: mainAxisExtent,
          ),
          builderDelegate: PagedChildBuilderDelegate<User>(
            itemBuilder: (context, user, index) {
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                splashColor: kPrimary.withOpacity(0.08),
                highlightColor: rowHoverColor,
                child: EmployeeCard(
                  textColor: textColor,
                  subColor: subColor,
                  pagingController: _pagingController,
                  employee: user,
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
