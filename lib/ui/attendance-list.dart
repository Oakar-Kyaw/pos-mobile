import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/attendance.api.dart';
import 'package:pos/component/delete-dialog.dart';
import 'package:pos/component/attendance-card.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/no-item-found-widget.dart';
import 'package:pos/localization/attendance-local.dart';
import 'package:pos/models/attendance.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/shad-toaster.dart';

class AttendanceList extends ConsumerStatefulWidget {
  const AttendanceList({super.key, this.userId, this.startDate, this.endDate});

  final int? userId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  ConsumerState<AttendanceList> createState() => AttendanceListState();
}

class AttendanceListState extends ConsumerState<AttendanceList> {
  late final PagingController<int, Attendance> _pagingController;
  final int limit = 31;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Attendance>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(attendanceProvider.notifier)
          .getAttendances(
            page: pageKey,
            limit: limit,
            filterUserId: widget.userId,
            startDate: widget.startDate,
            endDate: widget.endDate,
          ),
    );
    // ref.listenManual(provider, listener)
  }

  ///Expose a public method to refresh the list
  void refresh() {
    _pagingController.refresh();
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

  void _delete(Attendance attendance, bool isDark) {
    showDeleteDialog(
      context,
      title: AttendanceLocaleScreenLocale.attendanceDeleteConfirm.getString(
        context,
      ),
      isDark: isDark,
      submit: () async {
        await ref
            .read(attendanceProvider.notifier)
            .deleteAttendance(attendance.id)
            .then((data) {
              if (data) {
                ShowToast(
                  context,
                  description: Text(
                    AttendanceLocaleScreenLocale.attendanceDeleteSuccess
                        .getString(context),
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
                  AttendanceLocaleScreenLocale.attendanceDeleteFail.getString(
                    context,
                  ),
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
    final rowHoverColor = isDark
        ? kPrimary.withOpacity(0.06)
        : kPrimary.withOpacity(0.04);
    final user = ref.watch(userStateProvider);

    ref.listen<SelectedData?>(selectedDataStateProvider, (prev, next) {
      _pagingController.refresh();
    });

    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) =>
          PagedListView<int, Attendance>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<Attendance>(
              itemBuilder: (context, attendance, index) {
                //print("attendance is 😇 ${attendance.date}");
                return InkWell(
                  splashColor: kPrimary.withOpacity(0.08),
                  highlightColor: rowHoverColor,
                  child: AttendanceCard(
                    textColor: textColor,
                    subColor: subColor,
                    //pagingController: _pagingController,
                    attendance: attendance,
                    onDelete:
                        (user != null &&
                            (isAdmin(user.role) || isManager(user.role)))
                        ? () => _delete(attendance, isDark)
                        : null,
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
