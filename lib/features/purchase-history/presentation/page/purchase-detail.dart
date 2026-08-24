import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/features/purchase-history/data/model/purchase-item.dart';
import 'package:pos/features/purchase-history/data/model/purchase.dart';
import 'package:pos/features/supplier/presentation/provider/supplier-provider.dart';
import 'package:pos/localization/purchase-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PurchaseDetailPage extends ConsumerStatefulWidget {
  const PurchaseDetailPage({super.key, required this.purchase});

  final Purchase purchase;

  @override
  ConsumerState<PurchaseDetailPage> createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends ConsumerState<PurchaseDetailPage> {
  final _formKey = GlobalKey<ShadFormState>();

  Timer? _debounce;
  bool showAddField = false;
  final TextEditingController searchController = TextEditingController();

  late List<TextEditingController> qtyControllers;
  late List<TextEditingController> priceControllers;

  late TextEditingController discountController;
  late TextEditingController discountPercentController;
  late TextEditingController taxController;
  late TextEditingController deliveryFeeController;
  late TextEditingController packagingFeeController;
  late TextEditingController noteController;

  late List<PurchaseItem> purchaseItems;
  late Purchase purchase;

  @override
  void initState() {
    super.initState();
    purchase = widget.purchase;
    purchaseItems = widget.purchase.purchaseItems;
    qtyControllers = purchaseItems
        .map((e) => TextEditingController(text: e.quantity.toString()))
        .toList();

    priceControllers = purchaseItems
        .map((e) => TextEditingController(text: e.price.toString()))
        .toList();

    discountController = TextEditingController(
      text: widget.purchase.discount.toString(),
    );

    discountPercentController = TextEditingController(
      text: widget.purchase.discountPercent.toString(),
    );

    taxController = TextEditingController(text: widget.purchase.tax.toString());

    deliveryFeeController = TextEditingController(
      text: widget.purchase.deliveryFee.toString(),
    );

    packagingFeeController = TextEditingController(
      text: widget.purchase.packagingFee.toString(),
    );

    noteController = TextEditingController(text: widget.purchase.note ?? '');
  }

  Color get _accentColor {
    switch (purchase.status.toUpperCase()) {
      case 'RECEIVED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return kPrimary;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();

    for (final controller in qtyControllers) {
      controller.dispose();
    }

    for (final controller in priceControllers) {
      controller.dispose();
    }

    discountController.dispose();
    taxController.dispose();
    deliveryFeeController.dispose();
    noteController.dispose();

    super.dispose();
  }

  void onSearchChanged(String value) {
    print("value is 👨‍🏭 $value");
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ref
          .read(productProvider.notifier)
          .getProductLists("10", "10", search: value);
    });
  }

  double get totalAmount {
    double total = 0;

    for (int i = 0; i < qtyControllers.length; i++) {
      final qty = int.tryParse(qtyControllers[i].text) ?? 0;
      final price = double.tryParse(priceControllers[i].text) ?? 0;

      total += qty * price;
    }

    total += double.tryParse(taxController.text) ?? 0;
    total += double.tryParse(deliveryFeeController.text) ?? 0;
    total -= double.tryParse(discountController.text) ?? 0;

    return total;
  }

  void updatePurchase() {
    print("update data is ");
    final items = List.generate(
      purchaseItems.length,
      (index) => {
        "id": purchase.purchaseItems[index].id,
        "productId": purchase.purchaseItems[index].productId,
        "quantity": int.tryParse(qtyControllers[index].text) ?? 0,
        "price": double.tryParse(priceControllers[index].text) ?? 0,
      },
    );

    final payload = {
      "note": noteController.text,
      "discount": discountController.text,
      "tax": taxController.text,
      "deliveryFee": deliveryFeeController.text,
      "purchaseItems": items,
    };

    debugPrint("payload for purchase is ${payload.toString()}");

    /// call api here
    /// ref.read(purchaseProvider.notifier).updatePurchase(...)
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        title: Text(
          PurchaseLocale.purchaseDetail.getString(context),
          style: TextStyle(color: textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ShadForm(
          key: _formKey,
          child: Column(
            children: [
              ShadCard(
                backgroundColor: surfaceColor,
                child: Column(
                  children: [
                    _infoRow(
                      PurchaseLocale.purchaseSupplier.getString(context),
                      purchase.supplier?.name ?? '-',
                      textColor,
                      subColor,
                    ),

                    _infoRow(
                      PurchaseLocale.purchaseStatus.getString(context),
                      purchase.status,
                      _accentColor,
                      subColor,
                    ),

                    _infoRow(
                      PurchaseLocale.purchaseOrderDate.getString(context),
                      DateFormat(
                        'yyyy-MM-dd E',
                      ).format(purchase.orderDate.toLocal()),
                      textColor,
                      subColor,
                    ),

                    _infoRow(
                      PurchaseLocale.purchaseReceived.getString(context),
                      purchase.receivedDate != null
                          ? DateFormat(
                              'yyyy-MM-dd E',
                            ).format(purchase.receivedDate!.toLocal())
                          : "null",
                      textColor,
                      subColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  PurchaseLocale.purchaseItemCard.getString(context),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: textColor),
                ),
              ),

              const SizedBox(height: 12),

              ...List.generate(purchaseItems.length, (index) {
                final item = purchaseItems[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ShadCard(
                    backgroundColor: surfaceColor,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.product?.name ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: ShadInputFormField(
                                id: 'qty_$index',
                                readOnly: true,
                                controller: qtyControllers[index],
                                keyboardType: TextInputType.number,
                                label: Text(
                                  PurchaseLocale.purchaseQuantity.getString(
                                    context,
                                  ),
                                  style: TextStyle(color: subColor),
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: ShadInputFormField(
                                id: 'price_$index',
                                readOnly: true,
                                controller: priceControllers[index],
                                keyboardType: TextInputType.number,
                                label: Text(
                                  PurchaseLocale.purchasePrice.getString(
                                    context,
                                  ),
                                  style: TextStyle(color: subColor),
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              ShadInputFormField(
                id: 'discount',
                readOnly: true,
                controller: discountController,
                keyboardType: TextInputType.number,
                label: Text(
                  PurchaseLocale.purchaseDiscount.getString(context),
                  style: TextStyle(color: subColor),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              ShadInputFormField(
                id: 'discountPercent',
                readOnly: true,
                controller: discountPercentController,
                keyboardType: TextInputType.number,
                label: Text(
                  PurchaseLocale.purchaseDiscountPercent.getString(context),
                  style: TextStyle(color: subColor),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              ShadInputFormField(
                id: 'tax',
                readOnly: true,
                controller: taxController,
                keyboardType: TextInputType.number,
                label: Text(
                  PurchaseLocale.purchaseTax.getString(context),
                  style: TextStyle(color: subColor),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              ShadInputFormField(
                id: 'deliveryFee',
                readOnly: true,
                controller: deliveryFeeController,
                keyboardType: TextInputType.number,
                label: Text(
                  PurchaseLocale.purchaseDeliveryFee.getString(context),
                  style: TextStyle(color: subColor),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              ShadInputFormField(
                id: 'packagingFee',
                readOnly: true,
                controller: packagingFeeController,
                keyboardType: TextInputType.number,
                label: Text(
                  PurchaseLocale.purchasePackagingFee.getString(context),
                  style: TextStyle(color: subColor),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              ShadInputFormField(
                id: 'note',
                readOnly: true,
                controller: noteController,
                maxLines: 3,
                label: Text(
                  PurchaseLocale.purchaseNote.getString(context),
                  style: TextStyle(color: subColor),
                ),
              ),

              const SizedBox(height: 20),

              ShadCard(
                backgroundColor: surfaceColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      PurchaseLocale.purchaseTotalAmount.getString(context),
                      style: TextStyle(color: textColor),
                    ),
                    Text(
                      purchase.totalAmount.toStringAsFixed(0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(title, style: TextStyle(color: subColor)),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
