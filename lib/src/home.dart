import 'dart:async';
import 'dart:ui';

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
import 'package:pos/component/loading-component.dart';
import 'package:pos/core/network/socket/socket-provider.dart';
import 'package:pos/core/utils/bottom-navigation.dart';
import 'package:pos/core/widgets/app-local-notification.dart';
import 'package:pos/features/brand/presentation/provider/brand-provider.dart';
import 'package:pos/features/company/presentation/provider/company.riverpod.dart';
import 'package:pos/features/voucher/data/model/voucher-detail.dart';
import 'package:pos/localization/brand-local.dart';
import 'package:pos/localization/category-local.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/home-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/product.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:pos/riverpod/login-check.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/drawer.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/responsive.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/secure-storage.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:print_bluetooth_thermal/post_code.dart';
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
      paidStatus: PaidStatus.paid,
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
  void _onChangedCate(int? v) {
    debugPrint("category is $v");
    setState(() {
      categoryId = v;
    });
    _pagingController.refresh();
  }

  //brand on change
  void _onChangedBrand(int? v) {
    debugPrint("brand is $v");
    setState(() {
      brandId = v;
    });
    _pagingController.refresh();
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

    // Brand / Category list for the horizontal chips
    // (assumes AsyncValue<List<...>> with `id` and `name` on each item)
    final List<dynamic> brands = ref
        .watch(brandProvider)
        .maybeWhen(data: (d) => d as List<dynamic>, orElse: () => <dynamic>[]);
    final List<dynamic> categories = ref
        .watch(categoryProvider)
        .maybeWhen(data: (d) => d as List<dynamic>, orElse: () => <dynamic>[]);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: CustomerDrawer(
        isLoggedIn: ref.watch(checkLoginProvider),
      ).buildDrawer(context),
      appBar: CustomAppBar(
        title: company?.name ?? HomeScreenLocale.homeTitle.getString(context),
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(AppRoute.productBarcodeScan),
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
            // ── Search bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                cursorColor: kPrimary,
                style: TextStyle(
                  fontSize: FontSizeConfig.body1(context),
                  fontWeight: FontWeight.w500,
                  color: isDark ? kTextDark : Colors.black87,
                ),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: HomeScreenLocale.searchProduct.getString(context),
                  hintStyle: TextStyle(
                    fontSize: FontSizeConfig.body1(context),
                    color: isDark ? Colors.white : Colors.black45,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  prefixIcon: Icon(
                    LucideIcons.search,
                    size: 20,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 48),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: Icon(
                          LucideIcons.x,
                          size: 18,
                          color: isDark ? Colors.white : Colors.black54,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      );
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: kPrimary, width: 1.5),
                  ),
                ),
              ),
            ),

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
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      FontSizeConfig.body2(
                                                        context,
                                                      ),
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
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                      FontSizeConfig.body3(
                                                        context,
                                                      ),
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
                              const SizedBox(height: 6),
                            ]
                          : <Widget>[],

                      // ── Brand chips (horizontal scroll) ──
                      const SizedBox(height: 4),
                      HorizontalFilterChips(
                        title: BrandScreenLocale.brandTitle.getString(context),
                        icon: LucideIcons.tag,
                        isDark: isDark,
                        selectedId: brandId,
                        items: [
                          FilterChipItem(
                            id: null,
                            label: HomeScreenLocale.all.getString(context),
                          ),
                          ...brands.map(
                            (b) => FilterChipItem(
                              id: b.id as int?,
                              label: '${b.name}',
                            ),
                          ),
                        ],
                        onSelected: _onChangedBrand,
                      ),
                      const SizedBox(height: 12),

                      // ── Category chips (horizontal scroll) ──
                      HorizontalFilterChips(
                        title: CategoryScreenLocale.categoryTitle.getString(
                          context,
                        ),
                        icon: LucideIcons.layoutGrid,
                        isDark: isDark,
                        selectedId: categoryId,
                        items: [
                          FilterChipItem(
                            id: null,
                            label: HomeScreenLocale.all.getString(context),
                          ),
                          ...categories.map(
                            (c) => FilterChipItem(
                              id: c.id as int?,
                              label: '${c.title}',
                            ),
                          ),
                        ],
                        onSelected: _onChangedCate,
                      ),
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
                            firstPageProgressIndicatorBuilder: (_) =>
                                Center(child: LoadingWidget()),
                            newPageProgressIndicatorBuilder: (_) =>
                                Center(child: LoadingWidget()),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? kBgDark : kBgLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.10),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                BottomNavItem(
                  icon: LucideIcons.packageOpen,
                  label: DrawerScreenLocale.drawerProduct.getString(context),
                  onTap: () => context.pushNamed(AppRoute.product),
                ),
                BottomNavItem(
                  icon: LucideIcons.ticket,
                  label: VoucherScreenLocale.voucher.getString(context),
                  onTap: () => context.pushNamed(AppRoute.vouchers),
                ),
                BottomNavItem(
                  icon: LucideIcons.trendingUp,
                  label: DrawerScreenLocale.drawerIncome.getString(context),
                  onTap: () => context.pushNamed(AppRoute.income),
                ),
                BottomNavItem(
                  icon: LucideIcons.chartNoAxesCombined,
                  label: DrawerScreenLocale.drawerProfit.getString(context),
                  onTap: () => context.pushNamed(AppRoute.profitAndLoss),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Horizontal Filter Chips (Brand / Category)
// ─────────────────────────────────────────
class FilterChipItem {
  final int? id; // null = "အားလုံး"
  final String label;
  const FilterChipItem({required this.id, required this.label});
}

class HorizontalFilterChips extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<FilterChipItem> items;
  final int? selectedId;
  final ValueChanged<int?> onSelected;
  final bool isDark;

  const HorizontalFilterChips({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.selectedId,
    required this.onSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 15, color: kPrimary),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: FontSizeConfig.body2(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              final selected = item.id == selectedId;

              return GestureDetector(
                onTap: () => onSelected(item.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: selected
                        ? LinearGradient(colors: [kPrimary, kSecondary])
                        : null,
                    color: selected
                        ? null
                        : (isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.05)),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: kPrimary.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: FontSizeConfig.body2(context),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: FontSizeConfig.body3(context),
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
