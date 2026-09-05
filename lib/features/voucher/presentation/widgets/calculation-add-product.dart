// ── Add product ────────────────────────────────
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/models/product.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/riverpod/voucher-detail.dart';

void addProduct(
  WidgetRef ref,
  Product product,
  TextEditingController searchController,
  setState,
  bool showAddField,
) {
  ref
      .read(voucherDetailProvider.notifier)
      .addItem(
        ItemModel(
          id: product.id,
          productId: product.id,
          product: product,
          name: product.name,
          quantity: 1,
          price: product.price,
          photoUrl: product.photoUrl,
        ),
      );
  searchController.clear();
  setState(() => showAddField = false);
}
