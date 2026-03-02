import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/models/refund-item.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProductItemSearchField extends ConsumerStatefulWidget {
  final Function(String) onSearchChanged;
  final Function(RefundItem) onProductSelected;

  const ProductItemSearchField({
    super.key,
    required this.onSearchChanged,
    required this.onProductSelected,
  });

  @override
  ConsumerState<ProductItemSearchField> createState() =>
      _ProductItemSearchFieldState();
}

class _ProductItemSearchFieldState
    extends ConsumerState<ProductItemSearchField> {
  late final TextEditingController searchController;
  bool showSuggestions = false;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final progressColor = isDark ? kPrimary : kPrimary.withOpacity(0.8);

    final productsAsync = ref.watch(productProvider);

    return Column(
      children: [
        ShadInputFormField(
          controller: searchController,
          decoration: const ShadDecoration(
            secondaryFocusedBorder: ShadBorder.none,
          ),
          placeholder: Text(
            "Search product...",
            style: TextStyle(color: subColor),
          ),
          onChanged: (value) {
            widget.onSearchChanged(value);

            setState(() {
              showSuggestions = value.trim().isNotEmpty;
            });
          },
        ),

        const SizedBox(height: 15),

        if (!showSuggestions)
          const SizedBox()
        else
          productsAsync.when(
            data: (items) {
              if (items.isEmpty) return const SizedBox();

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kPrimary.withOpacity(0.2)),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final product = items[index];

                    return ListTile(
                      title: Text(
                        product.name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSizeConfig.body(context),
                        ),
                      ),
                      subtitle: Text(
                        product.code,
                        style: TextStyle(color: subColor),
                      ),
                      onTap: () {
                        searchController.text = product.name;

                        widget.onProductSelected.call(
                          RefundItem(
                            id: 0,
                            product: product,
                            productId: product.id,
                            quantity: 1,
                            price: product.price,
                            createdAt: DateTime.now(),
                          ),
                        );

                        setState(() {
                          showSuggestions = false;
                          searchController.clear();
                        });
                      },
                    );
                  },
                ),
              );
            },
            loading: () => Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(color: progressColor),
              ),
            ),
            error: (_, __) => const SizedBox(),
          ),
      ],
    );
  }
}
