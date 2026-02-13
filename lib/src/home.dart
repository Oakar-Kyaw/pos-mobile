import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/home-local.dart';
import 'package:pos/models/product.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/riverpod/voucher-detail.dart';
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
    // final voucher = ref.watch(voucherDetailProvider);
    // print(
    //   "selected voucher is 🥹: ${voucher?.items[0].name} ${voucher?.total}",
    // );
    return Scaffold(
      drawer: CustomerDrawer().buildDrawer(context),
      appBar: CustomAppBar(
        title: HomeScreenLocale.homeTitle.getString(context),
      ),

      body: Stack(
        children: [
          // ================= PRODUCT GRID =================
          PagingListener(
            controller: _pagingController,
            builder: (context, state, fetchNextPage) {
              return PagedGridView<int, Product>(
                padding: const EdgeInsets.only(bottom: 90),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.isTablet(context) ? 6 : 4,
                  mainAxisExtent: Responsive.isTablet(context) ? 150 : 120,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                state: state,
                fetchNextPage: fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate<Product>(
                  itemBuilder: (context, item, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Stack(
                        children: [
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _productImage(item),
                          ),

                          // Top-right checkbox
                          Positioned(
                            top: 5,
                            right: 5,
                            child: _selectCheckbox(item),
                          ),

                          // Bottom label
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 28,
                              alignment: Alignment.center,
                              color: Colors.black54,
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),

          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 120),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        alignment: Alignment.center,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          HomeScreenLocale.save.getString(context),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: FontSizeConfig.body(context),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () => context.pushNamed(AppRoute.createVoucher),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          HomeScreenLocale.createVoucher.getString(context),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: FontSizeConfig.body(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _productImage(Product item) {
    return SizedBox.expand(
      child: item.photoUrl != null
          ? Image.network(item.photoUrl!, fit: BoxFit.cover)
          : Image.asset("assets/default.jpg", fit: BoxFit.cover),
    );
  }

  Widget _selectCheckbox(Product item) {
    final isSelected =
        ref
            .watch(voucherDetailProvider)
            ?.items
            .any((selectedItem) => selectedItem.id == item.id) ??
        false;
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ShadCheckbox(
          value: isSelected,
          //value: checkSelectedItem(item.id),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                // Initialize voucher only if it's null
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
        ),
      ),
    );
  }
}
