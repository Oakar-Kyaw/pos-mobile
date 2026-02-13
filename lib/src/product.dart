import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/product-form.dart';
import 'package:pos/localization/product-local.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProductPage extends ConsumerWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(LucideIcons.arrowLeft),
        ),
        title: ProductScreenLocale.productTitle.getString(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Center(
              child: Text(
                ProductScreenLocale.productDescription.getString(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  height: 2,
                ),
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 10, bottom: 20),
                child: ProductForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
