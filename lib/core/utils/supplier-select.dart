import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/features/supplier/presentation/provider/supplier-provider.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/localization/purchase-local.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SupplierSelect extends ConsumerStatefulWidget {
  SupplierSelect({
    super.key,
    required this.onChanged,
    this.allSupplier = true,
    this.initialValue,
  });
  final ValueChanged<String?> onChanged;

  ///check all supplier or not
  bool allSupplier;
  //initial value
  final String? initialValue;

  @override
  ConsumerState<SupplierSelect> createState() => _SupplierSelectState();
}

class _SupplierSelectState extends ConsumerState<SupplierSelect> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();

    selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant SupplierSelect oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        selectedValue = widget.initialValue;
      });
    }
  }

  void _onChanged(String? value) {
    setState(() {
      selectedValue = value;
    });

    widget.onChanged.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final supplierAsync = ref.watch(supplierProvider);

    return supplierAsync.when(
      data: (suppliers) {
        /// Build options list
        final List<ShadOption<String>> shadOptions = [
          if (widget.allSupplier)
            ShadOption<String>(
              value: '',
              child: Text(GeneralScreenLocale.all.getString(context)),
            ),
          ...suppliers.map(
            (s) =>
                ShadOption<String>(value: s.id.toString(), child: Text(s.name)),
          ),
        ];

        /// default selection
        selectedValue ??= shadOptions.first.value;
        return ShadSelect<String>(
          initialValue: selectedValue,
          options: shadOptions,
          placeholder: Text(
            PurchaseLocale.purchaseSelectSupplier.getString(context),
          ),
          onChanged: _onChanged,
          selectedOptionBuilder: (context, value) {
            final option = shadOptions.firstWhere(
              (o) => o.value == value,
              orElse: () => ShadOption<String>(
                value: '',
                child: Text(PurchaseLocale.purchaseSupplier.getString(context)),
              ),
            );

            return option.child;
          },
        );
      },
      loading: () => const SizedBox(width: 100, child: LoadingWidget()),
      error: (err, stack) {
        return SizedBox(width: 200, child: Text('Error: $err'));
      },
    );
  }
}
