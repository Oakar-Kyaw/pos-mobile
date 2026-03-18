import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TimePicker extends ConsumerWidget {
  const TimePicker({
    super.key,
    required this.title,
    required this.onChanged,
    required this.timeController,
  });

  final Function(String time, String period, String? totalMinutes) onChanged;
  final String title;
  final ShadTimePickerController timeController;

  String formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String getPeriod(int hour) {
    return hour >= 12 ? 'PM' : 'AM';
  }

  String formatToMinutes(int hour, int minute) {
    final totalMinutes = hour * 60 + minute;
    return totalMinutes.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadTimePickerFormField(
      controller: timeController,
      showSeconds: false,
      gap: 10,
      spacing: 10,
      onChanged: (value) {
        if (value != null) {
          final time = formatTime(value.hour, value.minute);
          final period = getPeriod(value.hour);
          final minute = formatToMinutes(value.hour, value.minute);
          onChanged(time, period, minute);
        }
      },
      label: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
