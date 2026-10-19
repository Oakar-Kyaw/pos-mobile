import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/localization/home-local.dart';
import 'package:pos/models/product.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CustomProductSearchField<T> extends ConsumerStatefulWidget {
  final Function(String)? onSearchChanged;
  final Function(dynamic) onProductSelected;
  final T Function(Product item) itemBuilder;

  const CustomProductSearchField({
    super.key,
    this.onSearchChanged,
    required this.onProductSelected,
    required this.itemBuilder,
  });

  @override
  ConsumerState<CustomProductSearchField<T>> createState() =>
      _CustomProductSearchFieldState<T>();
}

class _CustomProductSearchFieldState<T>
    extends ConsumerState<CustomProductSearchField<T>> {
  static const int _searchLimit = 40;

  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  List<Product> _searchResults = [];
  bool _isSearchLoading = false;
  int _searchSeq = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged(String value) {
    widget.onSearchChanged?.call(value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _searchProducts(value.trim());
    });
  }

  Future<void> _searchProducts(String query) async {
    final seq = ++_searchSeq;

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearchLoading = false;
      });
      return;
    }

    setState(() => _isSearchLoading = true);

    try {
      final result = await ref
          .read(productProvider.notifier)
          .getProductLists("1", _searchLimit.toString(), search: query);

      if (!mounted || seq != _searchSeq) return;

      setState(() {
        _searchResults = List<Product>.from(result);
        _isSearchLoading = false;
      });
    } catch (e) {
      debugPrint('Search products error: $e');
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _searchResults = [];
        _isSearchLoading = false;
      });
    }
  }

  void _onSelectSearchResult(Product product) {
    widget.onProductSelected(widget.itemBuilder(product));
    _searchSeq++;
    setState(() {
      searchController.clear();
      _searchResults = [];
      _isSearchLoading = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    final hasQuery = searchController.text.trim().isNotEmpty;

    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: (v) {
            setState(() {});
            onSearchChanged(v);
          },
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(color: subColor),
            prefixIcon: Icon(LucideIcons.search, color: subColor),
            suffixIcon: _isSearchLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (hasQuery
                      ? IconButton(
                          icon: Icon(Icons.close, color: subColor),
                          onPressed: () {
                            _searchSeq++;
                            setState(() {
                              searchController.clear();
                              _searchResults = [];
                              _isSearchLoading = false;
                            });
                          },
                        )
                      : null),
            filled: true,
            fillColor: surfaceColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: subColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: subColor.withOpacity(0.3)),
            ),
          ),
        ),
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 280),
            child: Material(
              color: surfaceColor,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: subColor.withOpacity(0.3)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: subColor.withOpacity(0.2)),
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      product.name,
                      style: TextStyle(color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      product.price.toString(),
                      style: TextStyle(color: subColor),
                    ),
                    trailing: Icon(LucideIcons.plus, color: subColor, size: 22),
                    onTap: () => _onSelectSearchResult(product),
                  );
                },
              ),
            ),
          )
        else if (hasQuery && !_isSearchLoading)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              HomeScreenLocale.noItemFound.getString(context),
              style: TextStyle(color: subColor),
            ),
          ),
      ],
    );
  }
}
