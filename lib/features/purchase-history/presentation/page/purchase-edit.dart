import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/core/utils/date-select.dart';
import 'package:pos/core/utils/payment-row.dart';
import 'package:pos/core/utils/payment-select.dart';
import 'package:pos/core/widgets/info-row.dart';
import 'package:pos/features/purchase-history/data/model/purchase-item.dart';
import 'package:pos/features/purchase-history/data/model/purchase-payment.dart';
import 'package:pos/features/purchase-history/data/model/purchase.dart';
import 'package:pos/features/purchase-history/presentation/provider/purchase.api.dart';
import 'package:pos/features/purchase-history/presentation/widget/purchase-status-select.dart';
import 'package:pos/localization/purchase-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/customer-product-search-field.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:pos/localization/home-local.dart';
import 'package:pos/models/product.dart';

class PurchaseEditPage extends ConsumerStatefulWidget {
  const PurchaseEditPage({super.key, required this.purchase});

  final Purchase purchase;

  @override
  ConsumerState<PurchaseEditPage> createState() => _PurchaseEditPageState();
}

class _PurchaseEditPageState extends ConsumerState<PurchaseEditPage> {
  final _formKey = GlobalKey<ShadFormState>();

  Timer? _debounce;

  static const int _searchLimit = 40;
  List<Product> _searchResults = [];
  bool _isSearchLoading = false;
  int _searchSeq = 0;

  int? supplierId;
  String? status;
  DateTime? orderDate;
  DateTime? receivedDate;

  final TextEditingController searchController = TextEditingController();

  late List<TextEditingController> qtyControllers;
  late List<TextEditingController> priceControllers;
  late List<TextEditingController> sellingPriceControllers;

  late TextEditingController discountController;
  late TextEditingController discountPercentController;
  late TextEditingController taxController;
  late TextEditingController deliveryFeeController;
  late TextEditingController packagingFeeController;
  late TextEditingController noteController;

  late Purchase purchaseData;
  late List<TextEditingController> paymentAmountController;
  List<PurchasePayment> purchasePayment = [];
  double totalPaidAmount = 0.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    purchaseData = widget.purchase.copyWith(
      purchaseItems: widget.purchase.purchaseItems
          .map((item) => item.copyWith())
          .toList(),
    );

    qtyControllers = purchaseData.purchaseItems
        .map((item) => TextEditingController(text: item.quantity.toString()))
        .toList();

    priceControllers = purchaseData.purchaseItems
        .map((item) => TextEditingController(text: item.price.toString()))
        .toList();

    sellingPriceControllers = purchaseData.purchaseItems
        .map(
          (item) => TextEditingController(text: item.sellingPrice.toString()),
        )
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

    packagingFeeController = TextEditingController(
      text: purchaseData.packagingFee.toString(),
    );

    noteController = TextEditingController(text: purchaseData.note ?? '');

    supplierId = purchaseData.supplierId;
    status = purchaseData.status;
    orderDate = purchaseData.orderDate;

    purchasePayment = purchaseData.purchasePayments;

    paymentAmountController = purchasePayment
        .map((e) => TextEditingController(text: e.amount.toString()))
        .toList();
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

    for (final controller in sellingPriceControllers) {
      controller.dispose();
    }

    for (final p in paymentAmountController) {
      p.dispose();
    }

    discountController.dispose();
    discountPercentController.dispose();
    taxController.dispose();
    deliveryFeeController.dispose();
    packagingFeeController.dispose();
    noteController.dispose();

    super.dispose();
  }

  void onSearchChanged(String value) {
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
    addProduct(product);
    _searchSeq++;
    setState(() {
      searchController.clear();
      _searchResults = [];
      _isSearchLoading = false;
    });
    FocusScope.of(context).unfocus();
  }

  double get totalAmount {
    double total = 0;

    // Calculate item total
    for (int i = 0; i < qtyControllers.length; i++) {
      final qty = int.tryParse(qtyControllers[i].text) ?? 0;
      final price = double.tryParse(priceControllers[i].text) ?? 0;

      total += qty * price;
    }

    // Add tax and delivery fee
    total += double.tryParse(taxController.text) ?? 0;
    total += double.tryParse(deliveryFeeController.text) ?? 0;
    total += double.tryParse(packagingFeeController.text) ?? 0;

    // Fixed discount
    final discount = double.tryParse(discountController.text) ?? 0;

    // Percentage discount
    final discountPercent =
        double.tryParse(discountPercentController.text) ?? 0;

    final percentageDiscount = total * (discountPercent / 100);

    total -= discount;
    total -= percentageDiscount;

    return total < 0 ? 0 : total;
  }

  void addProduct(product) {
    setState(() {
      final tempId = -DateTime.now().microsecondsSinceEpoch;

      final item = PurchaseItem(
        id: tempId,
        product: product,
        productId: product.id,

        // This is the purchase ID,
        // NOT the product ID.
        purchaseId: purchaseData.id,

        quantity: 1,
        price: product.costPrice ?? 0,
        sellingPrice: product.price,
      );

      purchaseData.purchaseItems.add(item);

      qtyControllers.add(TextEditingController(text: '1'));

      priceControllers.add(
        TextEditingController(text: product.costPrice.toString()),
      );

      ///selling price
      sellingPriceControllers.add(
        TextEditingController(text: product.price.toString()),
      );
    });
  }

  void _addPayment(PaymentData v) {
    setState(() {
      final exists = purchasePayment.any((p) => p.paymentDataId == v.id);
      if (exists) return;

      purchasePayment.add(
        PurchasePayment(
          id: v.id,
          purchaseId: v.id,
          paymentDataId: v.id,
          amount: 0,
          type: v.accountType,
          paymentData: v,
        ),
      );
      paymentAmountController.add(TextEditingController(text: '0'));
    });
  }

  void updatePurchase() async {
    if (_isSubmitting) return;
    try {
      if (purchasePayment.isEmpty) throw AddPurchasePaymentError();

      final purchasePayments = List.generate(
        purchasePayment.length,
        (index) => {
          "paymentDataId": purchasePayment[index].paymentData!.id,
          "amount": double.tryParse(paymentAmountController[index].text) ?? 0,
          "type": purchasePayment[index].type,
        },
      );

      final items = List.generate(purchaseData.purchaseItems.length, (index) {
        final item = purchaseData.purchaseItems[index];

        return {
          "productId": item.productId,
          "quantity": int.tryParse(qtyControllers[index].text) ?? 0,
          "price": double.tryParse(priceControllers[index].text) ?? 0,
          "sellingPrice":
              double.tryParse(sellingPriceControllers[index].text) ?? 0,
        };
      });

      final payload = {
        "supplierId": supplierId,
        "orderDate": orderDate!.toIso8601String(),
        "receivedDate": receivedDate?.toIso8601String(),
        "status": status!.toUpperCase(),
        "note": noteController.text,

        "discount": double.tryParse(discountController.text) ?? 0,

        "tax": double.tryParse(taxController.text) ?? 0,

        "deliveryFee": double.tryParse(deliveryFeeController.text) ?? 0,

        "discountPercent": double.tryParse(discountPercentController.text) ?? 0,

        "packagingFee": double.tryParse(packagingFeeController.text) ?? 0,

        "purchaseItems": items,

        'purchasePayment': purchasePayments,
      };

      debugPrint("payload for purchase is $payload");
      if (!mounted) return;
      setState(() => _isSubmitting = true);
      // API call
      //
      final success = await ref
          .read(purchaseProvider.notifier)
          .updatePurchase(purchaseData.id, payload);

      if (success) {
        if (success) {
          ShowToast(
            context,
            description: Text(
              PurchaseLocale.purchaseUpdateSuccess.getString(context),
              style: TextStyle(color: kGreen),
            ),
            borderColor: kGreen,
          );
          context.pushNamed(AppRoute.purchaseHistory);
        }
      }
    } on AddPurchasePaymentError {
      print("error in add purchase");
      ShowToast(
        context,
        isError: true,
        description: Text(
          PurchaseLocale.purchaseAddPayment.getString(context),
          style: TextStyle(color: kRed),
        ),
        borderColor: kRed,
      );
    } catch (e, stackTrace) {
      debugPrint("Error creating purchase: $e");
      debugPrintStack(stackTrace: stackTrace);
      ShowToast(
        context,
        description: Text(
          PurchaseLocale.purchaseUpdateFail.getString(context),
          style: TextStyle(color: kRed),
        ),
        borderColor: kRed,
        isError: true,
      );
    }
  }

  void _onremoveItem(int index) {
    setState(() {
      // Dispose controllers first
      qtyControllers[index].dispose();
      priceControllers[index].dispose();
      sellingPriceControllers[index].dispose();
      // Remove controllers
      qtyControllers.removeAt(index);
      priceControllers.removeAt(index);
      sellingPriceControllers.removeAt(index);
      // Remove purchase item
      purchaseData.purchaseItems.removeAt(index);
    });
  }

  void _removePayment(int index) {
    setState(() {
      paymentAmountController[index].dispose();
      paymentAmountController.removeAt(index);
      purchasePayment.removeAt(index);
    });
  }

  double _calculateTotalPaidAmount() {
    return paymentAmountController.fold<double>(
      0.0,
      (sum, controller) => sum + (double.tryParse(controller.text) ?? 0.0),
    );
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
              // ============================
              // SUPPLIER / STATUS / DATE
              // ============================
              ShadCard(
                backgroundColor: surfaceColor,

                child: Column(
                  children: [
                    infoRowSupplier(
                      PurchaseLocale.purchaseSupplier.getString(context),

                      textColor,
                      subColor,

                      initialValue: supplierId?.toString(),

                      onChanged: (value) {
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

                      initialValue: changePurchaseStatus(status!),

                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          status = statusLabel(value);
                        });
                      },
                    ),

                    _infoRowSelectDate(
                      PurchaseLocale.purchaseOrderDate.getString(context),
                      textColor,
                      subColor,
                      (value) => setState(() => orderDate = value),
                    ),

                    if (status == "Success")
                      _infoRowSelectDate(
                        PurchaseLocale.purchaseReceivedDate.getString(context),
                        textColor,
                        subColor,
                        (value) => setState(() => receivedDate = value),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ============================
              // ADD PRODUCT
              // ============================
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

              CustomProductSearchField<Product>(
                itemBuilder: (product) => product,
                onProductSelected: (p) => addProduct(p as Product),
              ),

              const SizedBox(height: 12),

              // ============================
              // PURCHASE ITEMS
              // ============================
              ...List.generate(purchaseData.purchaseItems.length, (index) {
                final item = purchaseData.purchaseItems[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ShadCard(
                    backgroundColor: surfaceColor,
                    child: Column(
                      children: [
                        // ==========================
                        // PRODUCT NAME + DELETE
                        // ==========================
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.product?.name ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),

                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 25,
                              ),
                              tooltip: 'Delete',
                              onPressed: () => _onremoveItem(index),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ==========================
                        // QUANTITY + PRICE
                        // ==========================
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
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
                              flex: 5,
                              child: ShadInputFormField(
                                id: 'price_$index',
                                controller: priceControllers[index],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                label: Text(
                                  PurchaseLocale.purchaseBuyPrice.getString(
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
                              flex: 5,
                              child: ShadInputFormField(
                                id: 'selling_price_$index',
                                controller: sellingPriceControllers[index],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                label: Text(
                                  PurchaseLocale.purchaseSellingPrice.getString(
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

              // ============================
              // DISCOUNT
              // ============================
              ShadInputFormField(
                id: 'discount',

                controller: discountController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                label: Text(
                  PurchaseLocale.purchaseDiscount.getString(context),

                  style: TextStyle(color: subColor),
                ),

                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              // ============================
              // DISCOUNT %
              // ============================
              ShadInputFormField(
                id: 'discountPercent',

                controller: discountPercentController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                label: Text(
                  PurchaseLocale.purchaseDiscountPercent.getString(context),

                  style: TextStyle(color: subColor),
                ),

                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              // ============================
              // TAX
              // ============================
              ShadInputFormField(
                id: 'tax',

                controller: taxController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                label: Text(
                  PurchaseLocale.purchaseTax.getString(context),

                  style: TextStyle(color: subColor),
                ),

                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              // ============================
              // DELIVERY FEE
              // ============================
              ShadInputFormField(
                id: 'deliveryFee',

                controller: deliveryFeeController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                label: Text(
                  PurchaseLocale.purchaseDeliveryFee.getString(context),

                  style: TextStyle(color: subColor),
                ),

                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              // ============================
              // PACKAGING FEE
              // ============================
              ShadInputFormField(
                id: 'packagingFee',

                controller: packagingFeeController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                label: Text(
                  PurchaseLocale.purchasePackagingFee.getString(context),

                  style: TextStyle(color: subColor),
                ),

                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PaymentSelect(
                  allPayment: false,
                  onChanged: (PaymentData v) => _addPayment(v),
                ),
              ),

              const SizedBox(height: 12),

              ...List.generate(purchasePayment.length, (index) {
                final payment = purchasePayment[index];
                return PaymentRow(
                  index: index,
                  accountName: payment.paymentData!.accountName,
                  controller: paymentAmountController[index],
                  validator: (v) {
                    if (v.isEmpty || v == '0') {
                      return PurchaseLocale.purchaseInvalidAmount.getString(
                        context,
                      );
                    }
                    return null;
                  },
                  onAmountChanged: (_) {
                    setState(() {
                      totalPaidAmount = _calculateTotalPaidAmount();
                    });
                  },
                  onRemove: () => _removePayment(index),
                );
              }),

              // ============================
              // NOTE
              // ============================
              ShadInputFormField(
                id: 'note',

                controller: noteController,

                maxLines: 3,

                label: Text(
                  PurchaseLocale.purchaseNote.getString(context),

                  style: TextStyle(color: subColor),
                ),

                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 20),

              // ============================
              // TOTAL
              // ============================
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

              // ============================
              // UPDATE
              // ============================
              GradientSubmitButton(
                isSubmitting: _isSubmitting,
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

  Widget _infoRowSelectDate(
    String title,
    Color textColor,
    Color subColor,
    ValueChanged<DateTime> onPicked,
  ) {
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
            child: DateSelect(
              onChanged: (value) {
                if (value == null) return;
                onPicked(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
