import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/localization/general-local.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum PurchaseStatus { PENDING, SHIPPED, SUCCESS, FAILED }

class PurchaseStatusSelect extends StatefulWidget {
  const PurchaseStatusSelect({super.key, this.value, this.onChanged});

  final PurchaseStatus? value;
  final ValueChanged<PurchaseStatus?>? onChanged;

  @override
  State<PurchaseStatusSelect> createState() => _PurchaseStatusSelectState();
}

class _PurchaseStatusSelectState extends State<PurchaseStatusSelect> {
  PurchaseStatus? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant PurchaseStatusSelect oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      setState(() {
        _selectedValue = widget.value;
      });
    }
  }

  void _onChanged(PurchaseStatus? value) {
    setState(() {
      _selectedValue = value;
    });

    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return ShadSelect<PurchaseStatus>(
      initialValue: _selectedValue,

      placeholder: Text(GeneralScreenLocale.selectStatus.getString(context)),

      options: PurchaseStatus.values.map((status) {
        return ShadOption(value: status, child: Text(statusLabel(status)));
      }).toList(),

      selectedOptionBuilder: (context, value) {
        return Text(statusLabel(value));
      },

      onChanged: _onChanged,
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

PurchaseStatus changePurchaseStatus(String status) {
  switch (status.toUpperCase()) {
    case 'Pending':
      return PurchaseStatus.PENDING;

    case 'Shipped':
      return PurchaseStatus.SHIPPED;

    case 'Success':
      return PurchaseStatus.SUCCESS;

    case 'Failed':
      return PurchaseStatus.FAILED;

    default:
      return PurchaseStatus.PENDING;
  }
}
