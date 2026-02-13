import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/category-form.dart';
import 'package:pos/component/category-table.dart';
import 'package:pos/localization/category-local.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(LucideIcons.arrowLeft),
        ),
        title: CategoryScreenLocale.categoryTitle.getString(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          children: [
            Text(
              CategoryScreenLocale.categoryDescription.getString(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: FontSizeConfig.body(context),
                height: 2,
              ),
            ),
            SizedBox(height: 10),
            CategoryForm(),
            SizedBox(height: 15),
            Expanded(child: CategoryTable()),
          ],
        ),
      ),
    );
  }
}
