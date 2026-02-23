import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/category.api.dart';
import 'package:pos/localization/category-local.dart';
import 'package:pos/localization/error-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CategoryForm extends ConsumerStatefulWidget {
  const CategoryForm({super.key});

  @override
  ConsumerState<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<CategoryForm> {
  final _formKey = GlobalKey<ShadFormState>();
  TextEditingController title = TextEditingController();

  void submit() async {
    final categoryApi = await ref
        .read(categoryProvider.notifier)
        .postCategory({"title": title.text})
        .catchError((error) {
          String message;
          if (error.message == ErrorScreenLocale.unauthorized) {
            message = ErrorScreenLocale.unauthorized.getString(context);
          } else {
            message = error.toString();
          }

          ShowToast(
            context,
            action: Icon(LucideIcons.x, color: Colors.red),
            borderColor: Colors.red,
            description: Text(message, style: TextStyle(color: Colors.red)),
          );
        });
    if (categoryApi == true) {
      ShowToast(
        context,
        action: Icon(LucideIcons.circleCheck, color: kGreen),
        borderColor: kGreen,
        description: Text(
          CategoryScreenLocale.categoryCreateSuccess.getString(context),
        ),
      );
      title.clear();
      _formKey.currentState?.reset();
      ref.invalidate(categoryProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final labelColor = isDark ? kTextDark : kTextLight;

    return Container(
      child: ShadForm(
        key: _formKey,
        child: Column(
          children: [
            ShadInputFormField(
              controller: title,
              validator: (v) => (v == null || v.isEmpty)
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

            SizedBox(height: 20),

            // ── Submit button with indigo gradient ──
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, kSecondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ShadButton(
                  backgroundColor: Colors.transparent,
                  onPressed: () {
                    if (_formKey.currentState!.saveAndValidate()) {
                      submit();
                    }
                  },
                  child: Text(
                    CategoryScreenLocale.categoryButton.getString(context),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
