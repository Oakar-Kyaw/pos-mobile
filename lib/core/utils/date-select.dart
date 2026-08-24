import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/localization/general-local.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DateSelect extends ConsumerStatefulWidget {
  const DateSelect({super.key, required this.onChanged});
  final ValueChanged<DateTime?> onChanged;

  @override
  ConsumerState<DateSelect> createState() => _DateSelectState();
}

class _DateSelectState extends ConsumerState<DateSelect> {
  @override
  Widget build(BuildContext context) {
    return ShadDatePicker(
      closeOnSelection: true,
      formatDate: (date) {
        return '${_monthName(date.month)} ${date.day}, ${date.year}';
      },
      placeholder: Text(GeneralScreenLocale.selectDate.getString(context)),
      onChanged: widget.onChanged,
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
}
