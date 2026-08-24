import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DateRangeSelect extends ConsumerStatefulWidget {
  const DateRangeSelect({super.key});

  @override
  ConsumerState<DateRangeSelect> createState() => _DateRangeSelectState();
}

class _DateRangeSelectState extends ConsumerState<DateRangeSelect> {
  @override
  Widget build(BuildContext context) {
    return ShadDatePicker.range(
      placeholder: Text(GeneralScreenLocale.selectDateRange.getString(context)),
      onRangeChanged: (value) {
        if (!mounted || value == null) {
          return;
        }
        final start = value.start;
        final end = value.end;

        debugPrint('Start Date: $start');
        debugPrint('End Date: $end');

        ref.read(selectedDataStateProvider.notifier).setStartDate(start);

        ref.read(selectedDataStateProvider.notifier).setEndDate(end);
      },
    );
  }
}
