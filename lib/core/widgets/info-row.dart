import 'package:flutter/material.dart';
import 'package:pos/core/utils/date-select.dart';
import 'package:pos/core/utils/supplier-select.dart';
import 'package:pos/features/purchase-history/presentation/widget/purchase-status-select.dart';

Widget infoRowSupplier(
  String title,
  Color textColor,
  Color subColor, {
  String? initialValue,
  required ValueChanged<String?> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(title, style: TextStyle(color: subColor)),
        ),

        Expanded(
          flex: 5,
          child: SupplierSelect(
            initialValue: initialValue,
            allSupplier: false,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

Widget infoRowSelectDate(
  String title,
  Color textColor,
  Color subColor, {
  DateTime? selectedDate,
  required ValueChanged<DateTime?> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(title, style: TextStyle(color: subColor)),
        ),

        Expanded(
          flex: 5,

          child: DateSelect(
            value: selectedDate,
            onChanged: onChanged,
            // (value) {
            //   if (value == null) return;
            //   setState(() {
            //     orderDate = value;
            //   });
            // },
          ),
        ),
      ],
    ),
  );
}

Widget infoRowSelectPurchaseStatus(
  String title,
  Color textColor,
  Color subColor, {
  PurchaseStatus? initialValue,
  required ValueChanged<PurchaseStatus?> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(title, style: TextStyle(color: subColor)),
        ),

        Expanded(
          flex: 5,
          child: PurchaseStatusSelect(
            value: initialValue,
            onChanged: onChanged,
            // (value) {
            //   if (value == null) return;
            //   setState(() {
            //     status = statusLabel(value);
            //   });
            // },
          ),
        ),
      ],
    ),
  );
}
