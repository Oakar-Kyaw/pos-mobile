// ── Search field ───────────────────────────────
import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/features/voucher/presentation/widgets/calculation-suggestion.dart';
import 'package:pos/localization/home-local.dart';
import 'package:pos/models/product.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Widget buildSearchField(
  BuildContext context,
  WidgetRef ref,
  TextEditingController searchController,
  bool isDark,
  Color textColor,
  Color subColor,
  setState,
  bool showAddField, {
  onSearchChanged,
  required void Function(Product product) onAddProduct,
}) {
  return Column(
    children: [
      ShadInputFormField(
        controller: searchController,
        decoration: ShadDecoration(secondaryFocusedBorder: ShadBorder.none),
        placeholder: Text(
          HomeScreenLocale.searchProduct.getString(context),
          style: TextStyle(color: subColor),
        ),
        onChanged: onSearchChanged,
      ),
      buildSuggestions(
        ref,
        searchController,
        isDark,
        textColor,
        subColor,
        setState,
        showAddField,
        onAddProduct: (product) {
          searchController.clear();
          onAddProduct(product);
        },
      ),
    ],
  );
}
