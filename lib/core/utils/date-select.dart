import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/localization/general-local.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DateSelect extends ConsumerStatefulWidget {
  const DateSelect({super.key, this.value, this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;

  @override
  ConsumerState<DateSelect> createState() => _DateSelectState();
}

class _DateSelectState extends ConsumerState<DateSelect> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.value;
  }

  @override
  void didUpdateWidget(covariant DateSelect oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      setState(() {
        _selectedDate = widget.value;
      });
    }
  }

  void _onChanged(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });

    widget.onChanged?.call(date);
  }

  @override
  Widget build(BuildContext context) {
    print("selected Date is: 😁 $_selectedDate");
    return ShadDatePicker(
      closeOnSelection: true,
      selected: _selectedDate,

      formatDate: (date) {
        return '${_monthName(date.month)} ${date.day}, ${date.year}';
      },

      placeholder: Text(GeneralScreenLocale.selectDate.getString(context)),

      onChanged: _onChanged,
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
