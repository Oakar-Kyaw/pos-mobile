import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/category.api.dart';
import 'package:pos/localization/category-local.dart';
import 'package:pos/localization/error-local.dart';
import 'package:pos/models/category.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CategoryForm extends ConsumerStatefulWidget {
  final Category? category;
  final Function onClear;
  const CategoryForm({super.key, required this.onClear, this.category});

  @override
  ConsumerState<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<CategoryForm> {
  final _formKey = GlobalKey<ShadFormState>();
  final TextEditingController title = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      title.text = widget.category!.title;
    }
  }

  @override
  @override
  void didUpdateWidget(covariant CategoryForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update text whenever category title changes
    if (widget.category?.id != oldWidget.category?.id ||
        widget.category?.title != oldWidget.category?.title) {
      title.text = widget.category?.title ?? '';
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() {
      isLoading = true;
    });

    final isEdit = widget.category != null;

    try {
      bool result;

      if (isEdit) {
        result = await ref
            .read(categoryProvider.notifier)
            .updateCategory(
              id: widget.category!.id!,
              json: {"title": title.text},
            );
      } else {
        result = await ref.read(categoryProvider.notifier).postCategory({
          "title": title.text,
        });
      }

      if (result) {
        ShowToast(
          context,
          action: const Icon(LucideIcons.circleCheck, color: kGreen),
          borderColor: kGreen,
          description: Text(
            isEdit
                ? CategoryScreenLocale.categoryUpdateSuccess.getString(context)
                : CategoryScreenLocale.categoryCreateSuccess.getString(context),
          ),
        );

        title.clear();
        _formKey.currentState?.reset();
        ref.invalidate(categoryProvider);
        //category data clear
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

    final isEdit = widget.category != null;

    return ShadForm(
      key: _formKey,
      child: Column(
        children: [
          ShadInputFormField(
            controller: title,
            validator: (v) => (v.isEmpty)
                ? CategoryScreenLocale.categoryTitleError.getString(context)
                : null,
            label: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                CategoryScreenLocale.categoryName.getString(context),
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                ),
              ),
            ),
            placeholder: Text(
              CategoryScreenLocale.categoryDescriptionPlaceholder.getString(
                context,
              ),
              style: TextStyle(fontSize: FontSizeConfig.body(context)),
            ),
          ),

          const SizedBox(height: 20),

          /// Button with Circular Loader
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isEdit
                          ? CategoryScreenLocale.categoryEditButton.getString(
                              context,
                            )
                          : CategoryScreenLocale.categoryButton.getString(
                              context,
                            ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
