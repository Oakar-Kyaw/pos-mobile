import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/localization/general-local.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum PurchaseStatus { PENDING, SHIPPED, SUCCESS, FAILED }

class PurchaseStatusSelect extends StatelessWidget {
  const PurchaseStatusSelect({super.key, required this.onChanged, this.value});

  final PurchaseStatus? value;
  final ValueChanged<PurchaseStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ShadSelect<PurchaseStatus>(
      initialValue: value,
      placeholder: Text(GeneralScreenLocale.selectStatus.getString(context)),
      options: PurchaseStatus.values.map((status) {
        return ShadOption(value: status, child: Text(statusLabel(status)));
      }).toList(),
      selectedOptionBuilder: (context, value) {
        return Text(statusLabel(value));
      },
      onChanged: onChanged,
    );
  }
}

String statusLabel(PurchaseStatus status) {
  switch (status) {
    case PurchaseStatus.PENDING:
      return 'Pending';

    case PurchaseStatus.SHIPPED:
      return 'Shipped';

    case PurchaseStatus.SUCCESS:
      return 'Success';

    case PurchaseStatus.FAILED:
      return 'Failed';
  }
}
