// ── Suggestions ────────────────────────────────
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/models/product.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:flutter_localization/flutter_localization.dart';

Widget buildSuggestions(
  WidgetRef ref,
  TextEditingController searchController,
  bool isDark,
  Color textColor,
  Color subColor,
  setState,
  bool showAddField, {
  required void Function(Product product) onAddProduct,
}) {
  final filtered = ref.watch(productProvider).value ?? [];
  if (searchController.text.isEmpty) return const SizedBox();

  final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
  final dividerColor = isDark
      ? Colors.white.withOpacity(0.06)
      : const Color(0xFFF3F4F6);

  return Container(
    height: 300,
    decoration: BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? kPrimary.withOpacity(0.1)
              : Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: dividerColor),
      itemBuilder: (context, index) {
        final product = filtered[index];
        return Material(
          color: Colors.transparent,
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: product.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.photoUrl ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            height: 10,
                            width: 10,
                            child: const LoadingWidget(),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image_not_supported, size: 40),
                      )
                    : Image.asset("assets/default.jpg", fit: BoxFit.cover),
              ),
            ),
            title: Text(
              product.name,
              style: TextStyle(
                fontSize: FontSizeConfig.body(context),
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              "${VoucherScreenLocale.price.getString(context)}: ${product.price}",
              style: TextStyle(
                fontSize: FontSizeConfig.body(context),
                color: subColor,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.plus, color: kPrimary, size: 16),
            ),
            onTap: () => onAddProduct(product),
          ),
        );
      },
    ),
  );
}
