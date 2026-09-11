import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/features/low-stock/presentation/provider/low-stock.provider.dart';
import 'package:pos/localization/product-local.dart';
import 'package:pos/models/product.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LowStockList extends ConsumerStatefulWidget {
  const LowStockList({super.key});

  @override
  ConsumerState<LowStockList> createState() => _LowStockListState();
}

class _LowStockListState extends ConsumerState<LowStockList> {
  late final PagingController<int, Product> _pagingController;

  final int limit = 20;

  @override
  void initState() {
    super.initState();

    _pagingController = PagingController<int, Product>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(productProvider.notifier)
          .getLowStockProducts(
            page: pageKey,
            limit: limit,
            search: ref.watch(lowStockSearchProvider),
          ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    ref.listen<String>(lowStockSearchProvider, (prev, next) {
      _pagingController.refresh();
    });

    return RefreshIndicator(
      onRefresh: () async {
        _pagingController.refresh();
      },
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => PagedListView<int, Product>(
          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<Product>(
            itemBuilder: (context, product, index) {
              return _LowStockCard(
                product: product,
                isDark: isDark,
                textColor: textColor,
                subColor: subColor,
                stockLabel: ProductScreenLocale.lowStockStock.getString(
                  context,
                ),
                minStockLabel: ProductScreenLocale.lowStockMin.getString(
                  context,
                ),
              );
            },
            firstPageProgressIndicatorBuilder: (_) => LoadingWidget(),
            newPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: LoadingWidget()),
            ),
            noItemsFoundIndicatorBuilder: (_) => Center(
              child: Text(
                ProductScreenLocale.lowStockEmpty.getString(context),
                style: TextStyle(color: subColor, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LowStockCard extends StatelessWidget {
  const _LowStockCard({
    required this.product,
    required this.isDark,
    required this.textColor,
    required this.subColor,
    required this.stockLabel,
    required this.minStockLabel,
  });

  final Product product;
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final String stockLabel;
  final String minStockLabel;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final isOutOfStock = product.stock <= 0;
    final statusColor = isOutOfStock ? kRed : kAmber;
    final hasPhoto = product.photoUrl != null && product.photoUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.4)),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: hasPhoto
                ? CachedNetworkImage(
                    imageUrl: product.photoUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 44,
                      height: 44,
                      color: statusColor.withOpacity(0.12),
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 44,
                      height: 44,
                      color: statusColor.withOpacity(0.12),
                      child: Icon(
                        isOutOfStock
                            ? LucideIcons.packageX
                            : LucideIcons.triangleAlert,
                        color: statusColor,
                        size: 18,
                      ),
                    ),
                  )
                : Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(10),
                    color: statusColor.withOpacity(0.12),
                    child: Icon(
                      isOutOfStock
                          ? LucideIcons.packageX
                          : LucideIcons.triangleAlert,
                      color: statusColor,
                      size: 18,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: FontSizeConfig.title(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.code,
                  style: TextStyle(color: subColor, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Text(
                  product.barcode ?? "-",
                  style: TextStyle(color: subColor, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StockPill(
                      label: '$stockLabel: ${product.stock}',
                      color: isOutOfStock ? kRed : kAmber,
                    ),
                    const SizedBox(width: 6),
                    if (product.minStock != null)
                      _StockPill(
                        label: '$minStockLabel: ${product.minStock}',
                        color: subColor,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatAmount(product.price),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: FontSizeConfig.body(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockPill extends StatelessWidget {
  const _StockPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
