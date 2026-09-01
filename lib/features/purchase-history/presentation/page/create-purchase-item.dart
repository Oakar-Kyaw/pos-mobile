import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/core/utils/date-select.dart';
import 'package:pos/core/utils/payment-row.dart';
import 'package:pos/core/utils/payment-select.dart';
import 'package:pos/core/utils/supplier-select.dart';
import 'package:pos/features/create-voucher/presentation/widgets/calculation-search-field.dart';
import 'package:pos/features/purchase-history/data/model/purchase-item.dart';
import 'package:pos/features/purchase-history/data/model/purchase-payment.dart';
import 'package:pos/features/purchase-history/presentation/provider/purchase.api.dart';
import 'package:pos/features/purchase-history/presentation/widget/purchase-status-select.dart';
import 'package:pos/localization/purchase-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/models/product.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PurchaseCreatePage extends ConsumerStatefulWidget {
  const PurchaseCreatePage({super.key});

  @override
  ConsumerState<PurchaseCreatePage> createState() => _PurchaseCreatePageState();
}

class _PurchaseCreatePageState extends ConsumerState<PurchaseCreatePage> {
  final _formKey = GlobalKey<ShadFormState>();
  int? supplierId;
  String? status;
  DateTime? orderDate;
  Timer? _debounce;
  bool showAddField = false;
  final TextEditingController searchController = TextEditingController();
  List<PurchaseItem> purchaseItems = [];
  final TextEditingController discountController = TextEditingController();
  final TextEditingController discountPercentController =
      TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final TextEditingController deliveryFeeController = TextEditingController();
  final TextEditingController packagingFeeController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  late List<TextEditingController> qtyControllers;
  late List<TextEditingController> priceControllers;
  late List<TextEditingController> paymentAmountController;
  List<PurchasePayment> purchasePayment = [];
  double totalPaidAmount = 0.0;
  @override
  void initState() {
    super.initState();

    qtyControllers = purchaseItems
        .map((e) => TextEditingController(text: e.quantity.toString()))
        .toList();

    priceControllers = purchaseItems
        .map((e) => TextEditingController(text: e.price.toString()))
        .toList();

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

    for (final p in paymentAmountController) {
      p.dispose();
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

  void createPurchase() async {
    try {
      debugPrint("Creating purchase...");
      if (!mounted) return;

      if (purchasePayment.isEmpty) throw AddPurchasePaymentError();

      final purchasePayments = List.generate(
        purchasePayment.length,
        (index) => {
          "paymentDataId": purchasePayment[index].paymentData!.id,
          "amount": double.tryParse(paymentAmountController[index].text) ?? 0,
          "type": purchasePayment[index].type,
        },
      );

      if (supplierId == null) {
        debugPrint("Supplier is required");
        ShowToast(
          context,
          description: Text(
            PurchaseLocale.purchaseSupplierRequired.getString(context),
            style: TextStyle(color: kRed),
          ),
          borderColor: kRed,
          isError: true,
        );
        return;
      }

      if (status == null) {
        debugPrint("status is required");
        ShowToast(
          context,
          description: Text(
            PurchaseLocale.purchaseStatusRequired.getString(context),
            style: TextStyle(color: kRed),
          ),
          borderColor: kRed,
          isError: true,
        );
        return;
      }

      if (orderDate == null) {
        debugPrint("Order Date is required");
        ShowToast(
          context,
          description: Text(
            PurchaseLocale.purchaseOrderDateRequired.getString(context),
            style: TextStyle(color: kRed),
          ),
          borderColor: kRed,
          isError: true,
        );
        return;
      }

      if (purchaseItems.isEmpty) {
        debugPrint("Purchase Item is required");
        ShowToast(
          context,
          description: Text(
            PurchaseLocale.purchaseItemRequired.getString(context),
            style: TextStyle(color: kRed),
          ),
          borderColor: kRed,
          isError: true,
        );
        return;
      }

      final items = List.generate(
        purchaseItems.length,
        (index) => {
          // "id": purchaseItems[index].id,
          "productId": purchaseItems[index].productId,
          "quantity": int.tryParse(qtyControllers[index].text) ?? 0,
          "price": double.tryParse(priceControllers[index].text) ?? 0,
        },
      );

      final payload = {
        "supplierId": supplierId,
        "orderDate": orderDate?.toIso8601String(),
        "status": status!.toUpperCase(),
        "note": noteController.text,
        "discount": discountController.text.isEmpty
            ? 0
            : discountController.text,
        "discountPercent": discountPercentController.text.isEmpty
            ? 0
            : discountPercentController.text,
        "tax": taxController.text.isEmpty ? 0 : taxController.text,
        "deliveryFee": deliveryFeeController.text.isEmpty
            ? 0
            : deliveryFeeController.text,
        "packagingFee": packagingFeeController.text.isEmpty
            ? 0
            : int.tryParse(packagingFeeController.text) ?? 0,
        "purchaseItems": items,
        'purchasePayment': purchasePayments,
      };

      debugPrint("Payload for purchase: $payload");

      // call API here
      final success = await ref
          .read(purchaseProvider.notifier)
          .createPurchase(payload);
      if (success) {
        ShowToast(
          context,
          description: Text(
            PurchaseLocale.purchaseSuccess.getString(context),
            style: TextStyle(color: kGreen),
          ),
          borderColor: kGreen,
        );
        context.pushNamed(AppRoute.purchaseHistory);
      }
    } on AddPurchasePaymentError {
      ShowToast(
        context,
        isError: true,
        description: Text(
          PurchaseLocale.purchaseSuccess.getString(context),
          style: TextStyle(color: kRed),
        ),
        borderColor: kRed,
      );
    } catch (e, stackTrace) {
      debugPrint("Error creating purchase: $e");
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void addProduct(Product product) {
    setState(() {
      final tempId = -DateTime.now().microsecondsSinceEpoch;

      final item = PurchaseItem(
        id: tempId,
        product: product,
        productId: product.id,

        purchaseId: product.id,

        quantity: 1,
        price: product.price,
      );

      purchaseItems.add(item);

      qtyControllers.add(TextEditingController(text: '1'));

      priceControllers.add(
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

  void _removePayment(int index) {
    setState(() {
      paymentAmountController[index].dispose();
      paymentAmountController.removeAt(index);
      purchasePayment.removeAt(index);
    });
  }

  void _onremoveItem(int index) {
    setState(() {
      // Dispose controllers first
      qtyControllers[index].dispose();
      priceControllers[index].dispose();

      // Remove controllers
      qtyControllers.removeAt(index);
      priceControllers.removeAt(index);

      // Remove purchase item
      purchaseItems.removeAt(index);
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
                    _infoRowSupplier(
                      PurchaseLocale.purchaseSupplier.getString(context),
                      textColor,
                      subColor,
                      setState,
                    ),

                    _infoRowSelectPurchaseStatus(
                      PurchaseLocale.purchaseStatus.getString(context),
                      textColor,
                      subColor,
                      setState,
                    ),
                    _infoRowSelectDate(
                      PurchaseLocale.purchaseOrderDate.getString(context),
                      textColor,
                      subColor,
                      setState,
                    ),
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
                onAddProduct: addProduct,
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
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
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

              const SizedBox(height: 16),

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
                id: 'packagingFee',
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
                onPressed: createPurchase,
                text: PurchaseLocale.purchaseCreate.getString(context),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRowSupplier(
    String title,
    Color textColor,
    Color subColor,
    setState,
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
            child: SupplierSelect(
              allSupplier: false,
              onChanged: (value) {
                print("create purchase item 👨‍🏭 $value");
                if (value == null) return;
                setState(() {
                  supplierId = int.tryParse(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowSelectDate(
    String title,
    Color textColor,
    Color subColor,
    setState,
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
                setState(() {
                  orderDate = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowSelectPurchaseStatus(
    String title,
    Color textColor,
    Color subColor,
    setState,
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
            child: PurchaseStatusSelect(
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  status = statusLabel(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
