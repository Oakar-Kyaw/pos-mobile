import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/features/brand/data/model/brand.dart';
import 'package:pos/features/brand/presentation/provider/brand-provider.dart';
import 'package:pos/localization/brand-local.dart';
import 'package:pos/localization/error-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BrandForm extends ConsumerStatefulWidget {
  final Brand? brand;
  final Function onClear;
  const BrandForm({super.key, required this.onClear, this.brand});

  @override
  ConsumerState<BrandForm> createState() => _BrandFormState();
}

class _BrandFormState extends ConsumerState<BrandForm> {
  final _formKey = GlobalKey<ShadFormState>();
  final TextEditingController name = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.brand != null) {
      name.text = widget.brand!.name;
    }
  }

  @override
  @override
  void didUpdateWidget(covariant BrandForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update text whenever brand name changes
    if (widget.brand?.id != oldWidget.brand?.id ||
        widget.brand?.name != oldWidget.brand?.name) {
      name.text = widget.brand?.name ?? '';
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() {
      isLoading = true;
    });

    final isEdit = widget.brand != null;

    try {
      bool result;

      if (isEdit) {
        result = await ref
            .read(brandProvider.notifier)
            .updateBrand(id: widget.brand!.id!, json: {"name": name.text});
      } else {
        result = await ref.read(brandProvider.notifier).postBrand({
          "name": name.text,
        });
      }

      if (result) {
        ShowToast(
          context,
          action: const Icon(LucideIcons.circleCheck, color: kGreen),
          borderColor: kGreen,
          description: Text(
            isEdit
                ? BrandScreenLocale.brandUpdateSuccess.getString(context)
                : BrandScreenLocale.brandCreateSuccess.getString(context),
          ),
        );

        name.clear();
        _formKey.currentState?.reset();
        ref.invalidate(brandProvider);
        //brand data clear
        widget.onClear.call();
      }
    } catch (error) {
      String message;

      if (error.toString() == ErrorScreenLocale.unauthorized) {
        message = ErrorScreenLocale.unauthorized.getString(context);
      } else {
        message = error.toString();
      }

      ShowToast(
        context,
        action: const Icon(LucideIcons.x, color: Colors.red),
        borderColor: Colors.red,
        description: Text(message, style: const TextStyle(color: Colors.red)),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final labelColor = isDark ? kTextDark : kTextLight;

    final isEdit = widget.brand != null;

    return ShadForm(
      key: _formKey,
      child: Column(
        children: [
          ShadInputFormField(
            controller: name,
            validator: (v) => (v.isEmpty)
                ? BrandScreenLocale.brandTitleError.getString(context)
                : null,
            label: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                BrandScreenLocale.brandName.getString(context),
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                ),
              ),
            ),
            placeholder: Text(
              BrandScreenLocale.brandDescriptionPlaceholder.getString(context),
              style: TextStyle(fontSize: FontSizeConfig.body(context)),
            ),
          ),

          const SizedBox(height: 20),

          /// Button with Circular Loader
          /// ── Submit Button ─────────────────
          GradientSubmitButton(
            isSubmitting: isLoading,
            onPressed: () {
              if (!isLoading) submit();
              setState(() {
                isLoading = true;
              });
              return;
            },
            text: isEdit
                ? BrandScreenLocale.brandEditButton.getString(context)
                : BrandScreenLocale.brandButton.getString(context),
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
