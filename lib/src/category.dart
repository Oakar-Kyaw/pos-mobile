import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/category-form.dart';
import 'package:pos/component/category-card.dart';
import 'package:pos/localization/category-local.dart';
import 'package:pos/models/category.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/description-widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  Category? categoryData;
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    BoxDecoration categoryFormBoxDecoration = BoxDecoration(
      color: isDark ? kSurfaceDark : kSurfaceLight,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? kPrimary.withOpacity(0.06)
              : Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: CategoryScreenLocale.categoryTitle.getString(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            DescriptionWidget(
              isDark: isDark,
              description: CategoryScreenLocale.categoryDescription.getString(
                context,
              ),
              icon: LucideIcons.tag,
              subColor: subColor,
            ),
            const SizedBox(height: 20),

            CategoryFormTitle(textColor: textColor),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: categoryFormBoxDecoration,
              child: CategoryForm(
                category: categoryData,
                onClear: () => setState(() {
                  categoryData = null;
                }),
              ),
            ),

            const SizedBox(height: 20),

            CategoriesNameTitle(textColor: textColor),

            const SizedBox(height: 12),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: CategoryCard(
                  onEdit: (Category value) {
                    print("value is ${value.title}");
                    setState(() {
                      categoryData = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class CategoriesNameTitle extends StatelessWidget {
  const CategoriesNameTitle({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, kSecondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          CategoryScreenLocale.categoryName.getString(context),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'List',
            style: TextStyle(
              color: kPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryFormTitle extends StatelessWidget {
  const CategoryFormTitle({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, kSecondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          CategoryScreenLocale.categoryTitle.getString(context),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
