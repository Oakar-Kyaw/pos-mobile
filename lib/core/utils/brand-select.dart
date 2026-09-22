import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/features/brand/presentation/provider/brand-provider.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/localization/brand-local.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BrandSelect extends ConsumerStatefulWidget {
  BrandSelect({
    super.key,
    required this.onChanged,
    this.allBrands = true,
    this.noSelect = true,
    this.initialValue,
  });
  final ValueChanged<String?> onChanged;

  ///check all brand or not
  bool allBrands;

  //check select or not
  bool noSelect;

  //initial value
  final String? initialValue;

  @override
  ConsumerState<BrandSelect> createState() => _BrandSelectState();
}

class _BrandSelectState extends ConsumerState<BrandSelect> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();

    selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant BrandSelect oldWidget) {
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
    final brandsAsync = ref.watch(brandProvider);

    return brandsAsync.when(
      data: (brands) {
        /// Build options list
        final List<ShadOption<String>> shadOptions = [
          if (widget.allBrands)
            ShadOption<String>(
              value: '',
              child: Text(GeneralScreenLocale.all.getString(context)),
            ),
          ...brands.map(
            (b) =>
                ShadOption<String>(value: b.id.toString(), child: Text(b.name)),
          ),
        ];

        // check is not empty
        if (shadOptions.isEmpty) {
          return SizedBox(
            width: 200,
            child: Text(BrandScreenLocale.brandListEmpty.getString(context)),
          );
        }

        // 👇 noSelect == false ဖြစ်မှသာ default selection (first value) ကို auto-set လုပ်ပါ
        // noSelect == true ဆိုရင် placeholder ကိုပဲ ပြပြီး, user select မှသာ value ရှိအောင်ပါ
        if (widget.noSelect == false) {
          selectedValue ??= shadOptions.first.value;
        }

        return ShadSelect<String>(
          initialValue: selectedValue,
          options: shadOptions,
          placeholder: Text(
            BrandScreenLocale.brandSelectPlaceholder.getString(context),
          ),
          onChanged: _onChanged,
          selectedOptionBuilder: (context, value) {
            final option = shadOptions.firstWhere(
              (o) => o.value == value,
              orElse: () => ShadOption<String>(
                value: '',
                child: Text(
                  BrandScreenLocale.brandSelectPlaceholder.getString(context),
                ),
              ),
            );

            return option.child;
          },
        );
      },
      loading: () => const SizedBox(width: 50, child: LoadingWidget()),
      error: (err, stack) {
        return SizedBox(width: 200, child: Text('Something went wrong'));
      },
    );
  }
}
