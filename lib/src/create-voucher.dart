import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/models/product.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/utils/debounce.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CreateVoucherPage extends ConsumerStatefulWidget {
  const CreateVoucherPage({super.key});

  @override
  ConsumerState<CreateVoucherPage> createState() => _CreateVoucherPageState();
}

class _CreateVoucherPageState extends ConsumerState<CreateVoucherPage> {
  Timer? _debounce;
  bool showAddField = false;
  final TextEditingController searchController = TextEditingController();
  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ref
          .read(productProvider.notifier)
          .getProductByUserId("10", "10", search: value);
      //ref.invalidate(productProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final voucher = ref.watch(voucherDetailProvider);
    final notifier = ref.read(voucherDetailProvider.notifier);

    if (voucher == null) {
      return const Scaffold(body: Center(child: Text("No voucher")));
    }

    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: VoucherScreenLocale.title.getString(context),
      ),
      body: Column(
        children: [
          /// ================= ITEM LIST =================
          Expanded(
            child: ListView.builder(
              itemCount: voucher.items.length,
              itemBuilder: (context, index) {
                final item = voucher.items[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: item.photoUrl != null
                            ? SizedBox(
                                width: 50,
                                height: 50,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    item.photoUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : SizedBox(
                                width: 50,
                                height: 50,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    "assets/default.jpg",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: FontSizeConfig.body(context),
                          ),
                        ),
                        subtitle: Text(
                          "${VoucherScreenLocale.price.getString(context)}: ${item.price} x ${item.quantity}",
                          style: TextStyle(
                            fontSize: FontSizeConfig.body(context),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  notifier.updateVoucher(
                                    items: voucher.items
                                        .map(
                                          (e) => e.id == item.id
                                              ? e.copyWith(
                                                  quantity: e.quantity - 1,
                                                )
                                              : e,
                                        )
                                        .toList(),
                                  );
                                  notifier.calculate();
                                } else {
                                  notifier.removeItem(item.id);
                                }
                              },
                            ),
                            Text(
                              item.quantity.toString(),
                              style: TextStyle(
                                fontSize: FontSizeConfig.title(context),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                notifier.updateVoucher(
                                  items: voucher.items
                                      .map(
                                        (e) => e.id == item.id
                                            ? e.copyWith(
                                                quantity: e.quantity + 1,
                                              )
                                            : e,
                                      )
                                      .toList(),
                                );
                                notifier.calculate();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// ================= ADD SECTION =================
                    if (index == voucher.items.length - 1)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: showAddField
                            ? _buildSearchField()
                            : ShadButton(
                                onPressed: () {
                                  setState(() {
                                    showAddField = true;
                                  });
                                },
                                child: Text(
                                  VoucherScreenLocale.addItem.getString(
                                    context,
                                  ),
                                  style: TextStyle(
                                    fontSize: FontSizeConfig.body(context),
                                  ),
                                ),
                              ),
                      ),
                  ],
                );
              },
            ),
          ),
          Divider(),

          /// ================= TOTAL =================
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _rowTax(VoucherScreenLocale.tax.getString(context)),
                SizedBox(height: 10),
                _row(
                  VoucherScreenLocale.subtotal.getString(context),
                  voucher.subTotal,
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                _row(
                  VoucherScreenLocale.total.getString(context),
                  voucher.total,
                ),
                SizedBox(height: 10),
                _rowNote(VoucherScreenLocale.note.getString(context)),
                const SizedBox(height: 20),
                ShadButton(
                  onPressed: () {
                    print("Saved voucher: ${voucher.toJson()}");
                    notifier.clearVoucher();
                    context.pop();
                  },
                  child: Text(VoucherScreenLocale.save.getString(context)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= SEARCH FIELD =================
  Widget _buildSearchField() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ShadInputFormField(
                controller: searchController,
                decoration: ShadDecoration(
                  secondaryFocusedBorder: ShadBorder.none,
                ),
                placeholder: const Text("Search product..."),
                onChanged: onSearchChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildSuggestions(),
      ],
    );
  }

  /// ================= SUGGESTIONS =================
  Widget _buildSuggestions() {
    final filtered = ref.watch(productProvider).value ?? [];
    if (searchController.text.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final product = filtered[index];

          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 236, 236, 236),
              ),
            ),
            child: ListTile(
              leading: product.photoUrl != null
                  ? SizedBox(
                      width: 50,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product.photoUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        "assets/default.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
              title: Text(
                product.name,
                style: TextStyle(fontSize: FontSizeConfig.body(context)),
              ),
              subtitle: Text(
                "${VoucherScreenLocale.price.getString(context)}: ${product.price}",
                style: TextStyle(fontSize: FontSizeConfig.body(context)),
              ),
              onTap: () {
                _addProduct(product);
              },
            ),
          );
        },
      ),
    );
  }

  /// ================= ADD PRODUCT =================
  void _addProduct(Product product) {
    final notifier = ref.read(voucherDetailProvider.notifier);

    notifier.addItem(
      ItemModel(
        id: product.id,
        name: product.name,
        quantity: 1,
        price: product.price,
        photoUrl: product.photoUrl,
      ),
    );

    searchController.clear();

    setState(() {
      showAddField = false;
    });
  }

  Widget _rowTax(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          width: 80,
          child: ShadInputFormField(
            keyboardType: TextInputType.number,
            initialValue: "0",
            textAlign: TextAlign.right,
            decoration: ShadDecoration(secondaryFocusedBorder: ShadBorder.none),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              final val = double.tryParse(value) ?? 0.0;
              ref.read(voucherDetailProvider.notifier).updateVoucher(tax: val);
              ref.read(voucherDetailProvider.notifier).calculate();
            },
          ),
        ),
      ],
    );
  }

  Widget _rowNote(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 50),
        Expanded(
          child: ShadInputFormField(
            decoration: ShadDecoration(secondaryFocusedBorder: ShadBorder.none),
            onChanged: (value) {
              ref
                  .read(voucherDetailProvider.notifier)
                  .updateVoucher(note: value);
            },
          ),
        ),
      ],
    );
  }

  Widget _row(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value.toStringAsFixed(2)),
      ],
    );
  }
}
