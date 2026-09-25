import 'dart:async';
import 'dart:ui';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos/core/utils/voucher/os-printer-voucher.dart';
import 'package:printing/printing.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/category.api.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/core/network/socket/socket-provider.dart';
import 'package:pos/core/utils/brand-select.dart';
import 'package:pos/core/utils/categories-select.dart';
import 'package:pos/core/widgets/app-local-notification.dart';
import 'package:pos/features/brand/presentation/provider/brand-provider.dart';
import 'package:pos/features/company/presentation/provider/company.riverpod.dart';
import 'package:pos/features/voucher/data/model/voucher-detail.dart';
import 'package:pos/localization/brand-local.dart';
import 'package:pos/localization/category-local.dart';
import 'package:pos/localization/home-local.dart';
import 'package:pos/localization/product-local.dart';
import 'package:pos/models/product.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:pos/riverpod/login-check.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/drawer.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/responsive.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/secure-storage.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  late final PagingController<int, Product> _pagingController;
  int? categoryId;
  int? brandId;

  String limit = "40";
  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Product>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(productProvider.notifier)
          .getProductLists(
            pageKey.toString(),
            limit,
            search: _searchQuery.isEmpty ? null : _searchQuery,
            categoryId: categoryId,
            brandId: brandId,
          ),
    );
    _connect();
    _listenProductProgress();
  }

  final secureStorage = SecureStorage();

  // ── Search state ─────────────────────────────
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  StreamSubscription<Map<String, dynamic>>? _productProgressSubscription;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _searchQuery = value.trim();
      });
      _pagingController.refresh();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        _pagingController.refresh();
      }
    });
  }

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
    debugPrint("Select item: 📱 ${item.avgCostPrice}");
    ref.read(voucherDetailProvider.notifier).addItem(item);
  }

  void clearSelectedItem(int id) {
    ref.read(voucherDetailProvider.notifier).removeItem(id);
  }

  //connect socket
  void _connect() {
    final user = ref.read(userStateProvider);
    if (user == null) {
      return;
    }
    final socketClient = ref.read(socketClientProvider);
    socketClient.connect(
      baseUrl: "${dotenv.env["BACKEND_URL"]}/socket",
      userId: user.id,
    );
  }

  void _listenProductProgress() {
    final socketClient = ref.read(socketClientProvider);

    _productProgressSubscription = socketClient.productProgressStream.listen((
      data,
    ) async {
      try {
        final percent = (data['percent'] as num?)?.toInt() ?? 0;
        final processed = (data['processed'] as num?)?.toInt() ?? 0;
        final total = (data['total'] as num?)?.toInt() ?? 0;

        print('📦 Product progress: $percent%');
        print('📦 Processed: $processed / $total');

        if (total <= 0) {
          return;
        }

        // // Import completed
        if (percent >= 100 || processed >= total) {
          await AppLocalNotification().showProductCompletedNotification(
            notiId: 1001,
            title: 'Product Import Completed',
            body: '$processed of $total products imported successfully',
          );

          return;
        }

        // Import is still processing
        await AppLocalNotification().showProductUploadProgress(
          notiId: 1001,
          title: 'Product Import',
          body: 'Processing $processed of $total products',
          progress: processed,
          maxProgress: total,
        );
      } catch (e) {
        print('❌ Product progress notification error: $e');
      }
    });
  }

  //categories on change
  void _onChangedCate(v) {
    debugPrint("val is $v");
    setState(() {
      categoryId = v is String ? int.tryParse(v) : v as int?;
      _pagingController.refresh();
    });
  }

  //brand on change
  void _onChangedBrand(v) {
    debugPrint("val is $v");
    setState(() {
      brandId = v is String ? int.tryParse(v) : v as int?;
      _pagingController.refresh();
    });
  }

  //Product On Tap
  void _productOntap(VoucherDetailModel? voucher, Product item) {
    if (voucher == null) {
      _onChangedProduct(true, item);
      return;
    }
    final exists = voucher.items.any((s) => s.id == item.id);
    if (exists) {
      ref.read(voucherDetailProvider.notifier).updateQuantity(item.id, 1);
    } else {
      _onChangedProduct(true, item);
    }
  }

  //on change or on select product
  void _onChangedProduct(bool? value, Product item) {
    setState(() {
      if (value == true) {
        if (ref.read(voucherDetailProvider) == null) {
          setVoucher();
        }
        selectedItems(
          ItemModel(
            id: item.id,
            productId: item.id,
            product: item,
            name: item.name,
            quantity: 1,
            price: item.price,
            costPrice: item.costPrice ?? 0,
            avgCostPrice: item.avgCostPrice,
            photoUrl: item.photoUrl,
          ),
        );
      } else {
        clearSelectedItem(item.id);
      }
    });
  }

  void _createVoucher(VoucherDetailModel? voucher) {
    if (voucher == null || voucher.items.isEmpty) {
      ShowToast(
        context,
        isError: true,
        description: Text(
          HomeScreenLocale.pleaseAddProduct.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
      return;
    } else {
      context.pushNamed(AppRoute.createVoucher);
    }
  }

  @override
  void dispose() {
    _productProgressSubscription?.cancel();
    _pagingController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final company = ref.watch(companyStateProvider);
    final voucher = ref.watch(voucherDetailProvider);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: CustomerDrawer(
        isLoggedIn: ref.watch(checkLoginProvider),
      ).buildDrawer(context),
      appBar: _isSearching
          ? AppBar(
              backgroundColor: bgColor,
              leading: IconButton(
                onPressed: _toggleSearch,
                icon: const Icon(LucideIcons.arrowLeft),
              ),
              title: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                style: TextStyle(color: isDark ? kTextDark : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ),
            )
          : CustomAppBar(
              title:
                  company?.name ??
                  HomeScreenLocale.homeTitle.getString(context),
              actions: [
                IconButton(
                  onPressed: _toggleSearch,
                  icon: const Icon(LucideIcons.search),
                ),
                IconButton(
                  onPressed: () =>
                      context.pushNamed(AppRoute.productBarcodeScan),
                  icon: const Icon(LucideIcons.scanBarcode),
                ),
                IconButton(
                  onPressed: () {
                    context.pushNamed(AppRoute.printer);
                  },
                  icon: const Icon(LucideIcons.printer),
                ),
              ],
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(brandProvider);
          ref.invalidate(categoryProvider);
          _pagingController.refresh();
        },
        child: Column(
          children: [
            // ── Product Grid ─────────────────────────────
            Expanded(
              child: PagingListener(
                controller: _pagingController,
                builder: (context, state, fetchNextPage) {
                  return Column(
                    children: [
                      ...(voucher?.items.isNotEmpty ?? false)
                          ? [
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 110,
                                child: GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        mainAxisSpacing: 8,
                                        childAspectRatio: 0.9,
                                      ),
                                  itemCount: voucher!.items.length,
                                  itemBuilder: (context, index) {
                                    final selectedItem = voucher.items[index];

                                    return SizedBox(
                                      width: 90,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child:
                                                  selectedItem.photoUrl != null
                                                  ? CachedNetworkImage(
                                                      imageUrl:
                                                          selectedItem
                                                              .photoUrl ??
                                                          "",
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      "assets/default.jpg",
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 2,
                                            left: 2,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 1,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: kPrimary,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'x${selectedItem.quantity}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 2,
                                            right: 2,
                                            child: GestureDetector(
                                              onTap: () => clearSelectedItem(
                                                selectedItem.id,
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  3,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 25,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 5,
                                                    horizontal: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.black.withOpacity(
                                                      0.7,
                                                    ),
                                                    Colors.black.withOpacity(
                                                      0.4,
                                                    ),
                                                  ],
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                ),
                                              ),
                                              child: Text(
                                                selectedItem.name,
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
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              const SizedBox(height: 10),
                            ]
                          : <Widget>[],
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        BrandScreenLocale.brandTitle.getString(
                                          context,
                                        ),
                                        style: TextStyle(
                                          fontSize: FontSizeConfig.body(
                                            context,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: double.infinity,
                                        child: BrandSelect(
                                          noSelect: false,
                                          onChanged: (v) => _onChangedBrand(v),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        CategoryScreenLocale.categoryTitle
                                            .getString(context),
                                        style: TextStyle(
                                          fontSize: FontSizeConfig.body(
                                            context,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: double.infinity,
                                        child: CategoriesSelect(
                                          onChanged: (v) => _onChangedCate(v),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 10,
                      //     vertical: 10,
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.start,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Expanded(
                      //         flex: 3,
                      //         child: Text(
                      //           ProductScreenLocale.productTitle.getString(
                      //             context,
                      //           ),
                      //           style: TextStyle(fontWeight: FontWeight.bold),
                      //         ),
                      //       ),
                      //       const SizedBox(width: 5),
                      //       Expanded(
                      //         flex: 10,
                      //         child: Row(
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           children: [
                      //             Expanded(
                      //               flex: 4,
                      //               child: Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.center,
                      //                 mainAxisAlignment: MainAxisAlignment.center,
                      //                 children: [
                      //                   Text(
                      //                     BrandScreenLocale.brandTitle.getString(
                      //                       context,
                      //                     ),
                      //                     style: TextStyle(
                      //                       fontSize: FontSizeConfig.body(
                      //                         context,
                      //                       ),
                      //                       fontWeight: FontWeight.w600,
                      //                     ),
                      //                   ),
                      //                   const SizedBox(height: 6),
                      //                   SizedBox(
                      //                     width: double.infinity,
                      //                     child: BrandSelect(
                      //                       noSelect: false,
                      //                       onChanged: (v) => _onChangedBrand(v),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //             const SizedBox(width: 4),
                      //             Expanded(
                      //               flex: 3,
                      //               child: Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.center,
                      //                 mainAxisAlignment: MainAxisAlignment.center,
                      //                 children: [
                      //                   Text(
                      //                     CategoryScreenLocale.categoryTitle
                      //                         .getString(context),
                      //                     style: TextStyle(
                      //                       fontSize: FontSizeConfig.body(
                      //                         context,
                      //                       ),
                      //                       fontWeight: FontWeight.w600,
                      //                     ),
                      //                   ),
                      //                   const SizedBox(height: 6),

                      //                   SizedBox(
                      //                     width: double.infinity,
                      //                     child: CategoriesSelect(
                      //                       onChanged: (v) => _onChangedCate(v),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: PagedGridView<int, Product>(
                          padding: const EdgeInsets.only(
                            bottom: 100,
                            top: 8,
                            left: 8,
                            right: 8,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: Responsive.isDesktop(context)
                                    ? 7
                                    : Responsive.isTablet(context)
                                    ? 5
                                    : 3,
                                mainAxisExtent: Responsive.isDesktop(context)
                                    ? 200
                                    : Responsive.isTablet(context)
                                    ? 180
                                    : 160,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          state: state,
                          fetchNextPage: fetchNextPage,
                          builderDelegate: PagedChildBuilderDelegate<Product>(
                            itemBuilder: (context, item, index) {
                              return InkWell(
                                onTap: () => _productOntap(voucher, item),
                                child: _ProductCard(
                                  item: item,
                                  isDark: isDark,
                                  isSelected:
                                      voucher?.items.any(
                                        (s) => s.id == item.id,
                                      ) ??
                                      false,
                                  onChanged: (value) =>
                                      _onChangedProduct(value, item),
                                ),
                              );
                            },
                            firstPageProgressIndicatorBuilder: (_) => Center(
                              child: CircularProgressIndicator(color: kPrimary),
                            ),
                            newPageProgressIndicatorBuilder: (_) => Center(
                              child: CircularProgressIndicator(color: kPrimary),
                            ),
                            noItemsFoundIndicatorBuilder: (_) => Center(
                              child: Text(
                                HomeScreenLocale.noItemFound.getString(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Bottom Action Bar ─────────────────────────
            // voucher != null && voucher.items.isNotEmpty
            //     ? Positioned(
            //         bottom: 20,
            //         left: 0,
            //         right: 0,
            //         child: Center(
            //           child: ClipRRect(
            //             borderRadius: BorderRadius.circular(30),
            //             child: BackdropFilter(
            //               filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            //               child: Container(
            //                 padding: const EdgeInsets.symmetric(
            //                   vertical: 8,
            //                   horizontal: 10,
            //                 ),
            //                 decoration: BoxDecoration(
            //                   color: isDark
            //                       ? Colors.white.withOpacity(0.08)
            //                       : Colors.black.withOpacity(0.06),
            //                   borderRadius: BorderRadius.circular(30),
            //                   border: Border.all(
            //                     color: isDark
            //                         ? Colors.white.withOpacity(0.12)
            //                         : Colors.black.withOpacity(0.08),
            //                     width: 1,
            //                   ),
            //                 ),
            //                 child: Row(
            //                   mainAxisSize: MainAxisSize.min,
            //                   children: [
            //                     GradientSubmitButton(
            //                       onPressed: () =>
            //                           context.pushNamed(AppRoute.createVoucher),
            //                       text: HomeScreenLocale.createVoucher.getString(
            //                         context,
            //                       ),
            //                       width: 200,
            //                       circularNo: 20,
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       )
            //     : const SizedBox(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () => _createVoucher(voucher),
          backgroundColor: kPrimary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
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
                  padding: const EdgeInsets.all(4),
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
        ? CachedNetworkImage(
            imageUrl: item.photoUrl ?? "",
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(width: 65, height: 70, color: Colors.grey.shade200),
            errorWidget: (context, url, error) => Container(
              width: 65,
              height: 70,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported_outlined, size: 20),
            ),
          )
        : Image.asset("assets/default.jpg", fit: BoxFit.cover);
  }
}
