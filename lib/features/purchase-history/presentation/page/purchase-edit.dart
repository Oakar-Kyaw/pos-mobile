import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/core/widgets/info-row.dart';
import 'package:pos/features/create-voucher/presentation/widgets/calculation-search-field.dart';
import 'package:pos/features/purchase-history/data/model/purchase-item.dart';
import 'package:pos/features/purchase-history/data/model/purchase.dart';
import 'package:pos/features/purchase-history/presentation/widget/purchase-status-select.dart';
import 'package:pos/localization/purchase-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PurchaseEditPage extends ConsumerStatefulWidget {
  const PurchaseEditPage({super.key, required this.purchase});

  final Purchase purchase;

  @override
  ConsumerState<PurchaseEditPage> createState() => _PurchaseEditPageState();
}

class _PurchaseEditPageState extends ConsumerState<PurchaseEditPage> {
  final _formKey = GlobalKey<ShadFormState>();

  Timer? _debounce;
  bool showAddField = false;
  int? supplierId;
  String? status;
  DateTime? orderDate;
  final TextEditingController searchController = TextEditingController();

  late List<TextEditingController> qtyControllers;
  late List<TextEditingController> priceControllers;

  late TextEditingController discountController;
  late TextEditingController discountPercentController;

  late TextEditingController taxController;
  late TextEditingController deliveryFeeController;

  late TextEditingController noteController;

  late Purchase purchaseData;

  @override
  void initState() {
    super.initState();

    purchaseData = widget.purchase.copyWith(
      purchaseItems: widget.purchase.purchaseItems
          .map((item) => item.copyWith())
          .toList(),
    );
    qtyControllers = purchaseData.purchaseItems
        .map((e) => TextEditingController(text: e.quantity.toString()))
        .toList();

    priceControllers = purchaseData.purchaseItems
        .map((e) => TextEditingController(text: e.price.toString()))
        .toList();

    discountController = TextEditingController(
      text: purchaseData.discount.toString(),
    );

    discountPercentController = TextEditingController(
      text: purchaseData.discountPercent.toString(),
    );

    taxController = TextEditingController(text: purchaseData.tax.toString());

    deliveryFeeController = TextEditingController(
      text: purchaseData.deliveryFee.toString(),
    );

    noteController = TextEditingController(text: purchaseData.note ?? '');
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
      purchaseData.purchaseItems.length,
      (index) => {
        "id": purchaseData.purchaseItems[index].id,
        "productId": purchaseData.purchaseItems[index].productId,
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
          PurchaseLocale.purchaseEdit.getString(context),
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
                    infoRowSupplier(
                      PurchaseLocale.purchaseSupplier.getString(context),
                      textColor,
                      subColor,
                      initialValue: purchaseData.supplier?.id.toString() ?? "-",
                      onChanged: (value) {
                        print("create purchase item 👨‍🏭 $value");
                        if (value == null) return;
                        setState(() {
                          supplierId = int.tryParse(value);
                        });
                      },
                    ),

                    infoRowSelectPurchaseStatus(
                      PurchaseLocale.purchaseStatus.getString(context),
                      textColor,
                      subColor,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          status = statusLabel(value);
                        });
                      },
                    ),
                    infoRowSelectDate(
                      PurchaseLocale.purchaseOrderDate.getString(context),
                      textColor,
                      subColor,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          orderDate = value;
                        });
                      },
                    ),

                    // _infoRow(
                    //   PurchaseLocale.purchaseReceived.getString(context),
                    //   DateFormat(
                    //     'yyyy-MM-dd E HH:mm',
                    //   ).format(purchase.receivedDate.toLocal()),
                    //   textColor,
                    //   subColor,
                    // ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  PurchaseLocale.purchaseAddItem.getString(context),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: textColor),
                ),
              ),

              const SizedBox(height: 12),

              buildSearchField(
                context,
                ref,
                searchController,
                isDark,
                textColor,
                subColor,
                setState,
                showAddField,
                onSearchChanged: onSearchChanged,
                onAddProduct: (product) {
                  setState(() {
                    purchaseData.purchaseItems.add(
                      PurchaseItem(
                        id: product.id,
                        product: product,
                        productId: product.id,
                        purchaseId: product.id,
                        quantity: 1,
                        price: product.price,
                        // costPrice: product.costPrice ?? 0,
                      ),
                    );
                    qtyControllers.add(TextEditingController(text: '0'));
                    priceControllers.add(
                      TextEditingController(text: product.price.toString()),
                    );
                  });
                },
              ),

              const SizedBox(height: 12),

              ...List.generate(purchaseData.purchaseItems.length, (index) {
                final item = purchaseData.purchaseItems[index];

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

              const SizedBox(height: 12),

              ShadInputFormField(
                id: 'discountPercent',
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
                id: 'note',
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
                      totalAmount.toStringAsFixed(0),
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

              GradientSubmitButton(
                onPressed: updatePurchase,
                text: PurchaseLocale.purchaseUpdate.getString(context),
                width: double.infinity,
              ),
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
