import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/payment-data.api.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/home-local.dart';
import 'package:pos/models/product.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/riverpod/payment-list.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/drawer.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/responsive.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final String limit = "20";

  late final PagingController<int, Product> _pagingController =
      PagingController<int, Product>(
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => ref
            .read(productProvider.notifier)
            .getProductByUserId(pageKey.toString(), limit),
      );

  void setVoucher() {
    VoucherDetailModel voucherDetailModel = VoucherDetailModel(
      id: 0,
      items: [],
      payments: [],
      total: 0,
      type: "draft",
    );
    ref.read(voucherDetailProvider.notifier).setVoucher(voucherDetailModel);
  }

  void selectedItems(ItemModel item) {
    ref.read(voucherDetailProvider.notifier).addItem(item);
  }

  void clearSelectedItem(int id) {
    ref.read(voucherDetailProvider.notifier).removeItem(id);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;

    final paymentDataAsync = ref.watch(paymentDataProvider);
    paymentDataAsync.whenData(
      (value) => ref.read(paymentListProvider.notifier).setPaymentList(value),
    );

    return Scaffold(
      backgroundColor: bgColor,
      drawer: CustomerDrawer().buildDrawer(context),
      appBar: CustomAppBar(
        title: HomeScreenLocale.homeTitle.getString(context),
      ),
      body: Stack(
        children: [
          // ── Product Grid ─────────────────────────────
          PagingListener(
            controller: _pagingController,
            builder: (context, state, fetchNextPage) {
              return PagedGridView<int, Product>(
                padding: const EdgeInsets.only(
                  bottom: 100,
                  top: 8,
                  left: 8,
                  right: 8,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.isTablet(context) ? 6 : 4,
                  mainAxisExtent: Responsive.isTablet(context) ? 150 : 120,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                state: state,
                fetchNextPage: fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate<Product>(
                  itemBuilder: (context, item, index) {
                    return _ProductCard(
                      item: item,
                      isDark: isDark,
                      isSelected:
                          ref
                              .watch(voucherDetailProvider)
                              ?.items
                              .any((s) => s.id == item.id) ??
                          false,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            if (ref.read(voucherDetailProvider) == null) {
                              setVoucher();
                            }
                            selectedItems(
                              ItemModel(
                                id: item.id,
                                name: item.name,
                                quantity: 1,
                                price: item.price,
                                photoUrl: item.photoUrl,
                              ),
                            );
                          } else {
                            clearSelectedItem(item.id);
                          }
                        });
                      },
                    );
                  },
                  firstPageProgressIndicatorBuilder: (_) =>
                      Center(child: CircularProgressIndicator(color: kPrimary)),
                  newPageProgressIndicatorBuilder: (_) =>
                      Center(child: CircularProgressIndicator(color: kPrimary)),
                ),
              );
            },
          ),

          // ── Bottom Action Bar ─────────────────────────
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.12)
                            : Colors.black.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Save button
                        _ActionButton(
                          label: HomeScreenLocale.save.getString(context),
                          isDark: isDark,
                          gradient: false,
                          onTap: () {},
                        ),

                        const SizedBox(width: 8),

                        // Create Voucher button — gradient
                        _ActionButton(
                          label: HomeScreenLocale.createVoucher.getString(
                            context,
                          ),
                          isDark: isDark,
                          gradient: true,
                          onTap: () =>
                              context.pushNamed(AppRoute.createVoucher),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Product Card
// ─────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product item;
  final bool isDark;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const _ProductCard({
    required this.item,
    required this.isDark,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? kPrimary : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: kPrimary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Product image
            Positioned.fill(child: _productImage(item)),

            // Selected overlay
            if (isSelected)
              Positioned.fill(
                child: Container(color: kPrimary.withOpacity(0.15)),
              ),

            // Checkbox top-right
            Positioned(
              top: 5,
              right: 5,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? kPrimary : Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ShadCheckbox(value: isSelected, onChanged: onChanged),
                ),
              ),
            ),

            // Bottom label
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [
                            kPrimary.withOpacity(0.9),
                            kSecondary.withOpacity(0.85),
                          ]
                        : [
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.4),
                          ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productImage(Product item) {
    return item.photoUrl != null
        ? Image.network(item.photoUrl!, fit: BoxFit.cover)
        : Image.asset("assets/default.jpg", fit: BoxFit.cover);
  }
}

// ─────────────────────────────────────────
// Action Button
// ─────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.isDark,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 120),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: gradient
              ? const LinearGradient(
                  colors: [kPrimary, kSecondary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: gradient
              ? null
              : (isDark ? Colors.white.withOpacity(0.12) : Colors.white),
          borderRadius: BorderRadius.circular(22),
          boxShadow: gradient
              ? [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: FontSizeConfig.body(context),
            color: gradient
                ? Colors.white
                : (isDark ? Colors.white : kTextLight),
          ),
        ),
      ),
    );
  }
}
