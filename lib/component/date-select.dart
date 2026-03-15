import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DateSelect extends ConsumerStatefulWidget {
  const DateSelect({super.key});

  @override
  ConsumerState<DateSelect> createState() => _DateSelectState();
}

class _DateSelectState extends ConsumerState<DateSelect> {
  @override
  Widget build(BuildContext context) {
    return ShadDatePicker.range(
      placeholder: Text(GeneralScreenLocale.selectDateRange.getString(context)),
      onRangeChanged: (value) {
        // value is List<DateTime> or DateTimeRange depending on version
        if (value != null) {
          final start = value.start;
          final end = value.end;
          //print("Start Date: $start, End Date: $end");

          // Update your Riverpod state
          ref.read(selectedDataStateProvider.notifier).setStartDate(start);
          ref.read(selectedDataStateProvider.notifier).setEndDate(end);
        }
      },
    );
  }
}
