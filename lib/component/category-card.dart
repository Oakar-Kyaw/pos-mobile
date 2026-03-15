import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/category.api.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/localization/category-local.dart';
import 'package:pos/models/category.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CategoryCard extends ConsumerWidget {
  final ValueChanged<Category> onEdit;
  const CategoryCard({super.key, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    final categoryAsync = ref.watch(categoryProvider);
    if (categoryAsync.isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (categoryAsync.hasError) {
      return const Center(child: Text("Failed to load categories"));
    }

    final data = categoryAsync.value ?? [];
    if (data.isEmpty) {
      return Center(
        child: Text(
          CategoryScreenLocale.categoryListEmpty.getString(context),
          style: TextStyle(color: subColor),
        ),
      );
    }

    void _delete(int id) {
      ref
          .read(categoryProvider.notifier)
          .deleteCategory(id)
          .then((data) {
            if (data) {
              ShowToast(
                context,
                description: Text(
                  CategoryScreenLocale.categoryDeleteSuccess.getString(context),
                ),
              );
              ref.invalidate(categoryProvider);
            }
          })
          .catchError((err) {
            ShowToast(
              context,
              description: Text(
                CategoryScreenLocale.categoryDeleteError.getString(context),
              ),
              isError: true,
            );
          });
    }

    return ListView.builder(
      //padding: const EdgeInsets.all(12),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final cate = data[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? kSurfaceDark : kSurfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? kPrimary.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.tag, color: kPrimary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cate.title,
                  style: TextStyle(
                    fontSize: FontSizeConfig.title(context),
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: FontSizeConfig.iconSize(context),
                    ),
                    color: Colors.green,
                    onPressed: () => onEdit(cate),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: FontSizeConfig.iconSize(context),
                    ),
                    color: Colors.red,
                    onPressed: () => _delete(cate.id!),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
