import 'package:intl/intl.dart';

String formatAmount(double value) {
  final formatter = NumberFormat('#,##0.##');
  return formatter.format(value);
}
